# Global Scope
root = exports ? this


class root.CtrlKeyAction
  key: null
  action: ''

  constructor: (editor) ->
    @editor = editor
    @initEvents()

  initEvents: ->
    @editor.on 'keydown', (event) =>
      if (event.ctrlKey or event.metaKey) and event.which == @key
        event.preventDefault()
        @editor.exec @action


class root.BoldText extends CtrlKeyAction
  key: 66
  action: 'bold'


class root.ItalicText extends CtrlKeyAction
  key: 73
  action: 'italic'


class root.Underline extends CtrlKeyAction
  key: 85
  action: 'underline'
