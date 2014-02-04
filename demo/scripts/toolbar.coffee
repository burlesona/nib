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

setOnOffHandlers = (editor, name, el) ->
  editor.on "report:#{name}:on", () ->
    el.style.fontWeight = 'bold'

  editor.on "report:#{name}:off", () ->
    el.style.fontWeight = 'normal'

setHandlers = (editor, name) ->
  link = document.getElementById(name)

  setOnOffHandlers(editor, name, link)

  link.addEventListener 'click', (event) ->
    event.preventDefault()
    editor[link.dataset.method]()
    false

createLinkHandlers = (editor) ->
  #link = document.getElementById('link')
  #setOnOffHandlers(editor, 'link', link)
  #link.addEventListener 'click', (event) ->
  #  event.preventDefault()
  #  editor.createLink(prompt('URL:'))
  #  false

  link2 = document.getElementById('link2')
  setOnOffHandlers(editor, 'link2', link2)

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

  editor.on "report:link2:on", (nodes) ->
    if nodes.length == 1
      node = nodes[0]
      toolbarDialog.showLinkDialog(node.href)

  editor.on "report:link2:off", (nodes) ->
    linkDialog.hide()
    linkDialog.getElement('.content').value = ''

root.initToolbar = (editor) ->
  setHandlers(editor, name) for name in [
    'bold', 'italic', 'underline', 'strikethrough',
    'subscript', 'superscript', 'outdent', 'indent',
    'bold2',
  ]
  createLinkHandlers(editor)
