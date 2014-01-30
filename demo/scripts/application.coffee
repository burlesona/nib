# Sample Editor initialization

# This UI code is not part of the editor, but merely a demonstration of how
# to create a UI that can call an editor instance.

root = exports ? this

el = document.getElementById 'testblock'
root.ed = new Editor
  node: el,
  plugins: ['bold', 'italic', 'underline', 'strikethrough',
            'subscript', 'superscript', 'link', 'outdent',
            'indent', 'bold2']

ed.activate (editor) ->
  editor.node.className += ' editing'

root.initToolbar(ed)
