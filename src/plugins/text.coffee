# Global Scope
root = exports ? this

class root.MetaKeyAction
  key: null
  action: ''
  constructor: (editor) ->
    @editor = editor
    @editor.on 'keydown', (event) =>
      if (event.ctrlKey or event.metaKey) and event.which == @key
        event.preventDefault()
        @editor.exec @action


class root.BoldText extends MetaKeyAction
  key: 66
  action: 'bold'


class root.ItalicText extends MetaKeyAction
  key: 73
  action: 'italic'


class root.Underline extends MetaKeyAction
  key: 85
  action: 'underline'
