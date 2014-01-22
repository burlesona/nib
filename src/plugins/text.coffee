# Global Scope
root = exports ? this

class root.BoldText
  constructor: (editor) ->
    editor.events.on 'keydown', (ev) ->
      if ev.ctrlKey and ev.which == 66
        ev.preventDefault()
        editor.exec 'bold'


class root.ItalicText
  constructor: (editor) ->
    editor.events.on 'keydown', (ev) ->
      if ev.ctrlKey and ev.which == 73
        ev.preventDefault()
        editor.exec 'italic'


class root.Underline
  constructor: (editor) ->
    editor.events.on 'keydown', (ev) ->
      if ev.ctrlKey and ev.which == 85
        ev.preventDefault()
        editor.exec 'underline'
