# Sample Toolbar

# This UI code is not part of the editor, but merely a demonstration of how
# to create a UI that can call an editor instance.

root = exports ? this


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
    document.querySelector('#link-dialog').classList.remove 'hidden'
    editor.createLink2 'http://'
    t = document.querySelector('#link-text')
    t.value = 'http://'
    t.focus()
    false

  document.querySelector('#link-save').addEventListener 'click', (event) ->
    event.preventDefault()
    editor.updateLink document.querySelector('#link-text').value
    document.querySelector('#link-dialog').classList.add 'hidden'
    false

  document.querySelector('#link-cancel').addEventListener 'click', (event) ->
    event.preventDefault()
    editor.removeLink()
    false

  editor.on "report:link2:on", (nodes) ->
    if nodes.length == 1
      node = nodes[0]
      document.querySelector('#link-dialog').classList.remove 'hidden'
      document.querySelector('#link-text').value = node.href

  editor.on "report:link2:off", (nodes) ->
    document.querySelector('#link-dialog').classList.add 'hidden'
    document.querySelector('#link-text').value = ''


root.initToolbar = (editor) ->
  setHandlers(editor, name) for name in [
    'bold', 'italic', 'underline', 'strikethrough',
    'subscript', 'superscript', 'outdent', 'indent',
    'bold2',
  ]
  createLinkHandlers(editor)





  
