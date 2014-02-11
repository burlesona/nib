# Sample Toolbar

# This UI code is not part of the editor, but merely a demonstration of how
# to create a UI that can call an editor instance.
root = exports ? this

class root.ToolbarDialogItem
  constructor: (element) ->
    @setRoot(element)

  show: () ->
    @root.classList.remove('hidden')

  hide: () ->
    @root.classList.add('hidden')

  setRoot: (element) ->
    @root = element

  getElement: (selector) ->
    @root.querySelector(selector)

class root.ToolbarDialogs extends root.ToolbarDialogItem
  constructor: (@container) ->
    super(@container.contentDocument)

    @linkDialog = @initializeDialogItem('link-dialog')
    @fnDialog = @initializeDialogItem('fn-dialog')
    @ktDialog = @initializeDialogItem('kt-dialog')

  initializeDialogItem: (id) ->
    new root.ToolbarDialogItem(@getElement("##{id}"))

  showLinkDialog: (url, focus = false) ->
    @linkDialog.show()
    content = @linkDialog.getElement('.content')
    content.value = url
    content.focus() if focus

toolbarDialog = new root.ToolbarDialogs(
  document.getElementById('dialogs')
)

setOnOffHandlers = (editor, names) ->
  editor.on 'report', (opts, editor) ->
    for state in opts.states
      el = document.getElementById(state)
      el.style.fontWeight = 'bold'
    for name in names
      if name not in opts.states
        el = document.getElementById(state)
        el.style.fontWeight = 'normal'

setHandlers = (editor, name) ->
  link = document.getElementById(name)
  link.addEventListener 'click', (event) ->
    event.preventDefault()
    editor[link.dataset.method]()
    false

createLinkHandlers = (editor) ->
  link = document.getElementById('link')
  link.addEventListener 'click', (event) ->
    event.preventDefault()
    editor.createLink(prompt('URL:'))
    false

  link2 = document.getElementById('link2')
  link2.addEventListener 'click', (event) ->
    event.preventDefault()
    toolbarDialog.showLinkDialog('http://', true)
    false

  linkDialog = toolbarDialog.linkDialog
  linkDialog.getElement('.save').addEventListener 'click', (event) ->
    event.preventDefault()
    url = linkDialog.getElement('.content').value
    editor.createLink2(url)
    linkDialog.hide()
    false

  linkDialog.getElement('.remove').addEventListener 'click', (event) ->
    event.preventDefault()
    editor.removeLink2()
    false

  editor.on 'report', (opts, editor) ->
    if 'link2' in opts.states
      node = editor.plugins.link2.selectionNodes(opts.nodes)[0]
      toolbarDialog.showLinkDialog(node.href)
    else
      linkDialog.hide()
      linkDialog.getElement('.content').value = ''

root.initToolbar = (editor) ->
  names = ['bold', 'italic', 'underline', 'strikethrough',
           'subscript', 'superscript', 'outdent', 'indent',
           'bold2']
  setHandlers(editor, name) for name in names
  setOnOffHandlers(editor, names)
  createLinkHandlers(editor)
