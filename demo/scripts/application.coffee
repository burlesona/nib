# Sample Editor initialization

# This UI code is not part of the editor, but merely a demonstration of how
# to create a UI that can call an editor instance.

root = exports ? this

el = document.getElementById 'testblock'
ed = new Editor
  node: el,
  plugins: ['BoldText', 'ItalicText', 'Underline',
            'StrikeThrough', 'Subscript', 'Superscript']

ed.activate()
root.initToolbar(ed)
