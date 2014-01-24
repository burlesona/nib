# Sample Toolbar

# This UI code is not part of the editor, but merely a demonstration of how
# to create a UI that can call an editor instance.

root = exports ? this


setHandlers = (editor, name) ->
  link = document.getElementById(name)

  editor.on "report:#{name}:on", () ->
    link.style.fontWeight = 'bold'

  editor.on "report:#{name}:off", () ->
    link.style.fontWeight = 'normal'

  link.addEventListener 'click', (event) ->
    event.preventDefault()
    editor[link.dataset.method]()
    false


root.initToolbar = (editor) ->
  setHandlers(editor, name) for name in [
    'bold', 'italic', 'underline', 'strikethrough',
    'subscript', 'superscript'
  ]
