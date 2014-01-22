# Global Scope
root = exports ? this

class root.MetaKeyAction
  key: null
  method: ''
  constructor: (editor) ->
    @editor = editor
    @editor.on 'keydown', (event) =>
      if (event.ctrlKey or event.metaKey) and event.which == @key
        event.preventDefault()
        if @editor[@method]?
          @editor[@method]()


class root.BoldText extends MetaKeyAction
  key: 66  # key: b
  method: 'toggleBold'


class root.ItalicText extends MetaKeyAction
  key: 73  # key: i
  method: 'toggleItalic'


class root.Underline extends MetaKeyAction
  key: 85  # key: u
  method: 'toggleUnderline'
