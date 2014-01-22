# Global Scope
root = exports ? this

class root.BoldText
  constructor: (editor) ->
    editor.events.on 'keydown', (event) ->
      if event.ctrlKey and event.which == 66
        event.preventDefault()
        editor.exec 'bold'


class root.ItalicText
  constructor: (editor) ->
    editor.events.on 'keydown', (event) ->
      if event.ctrlKey and event.which == 73
        event.preventDefault()
        editor.exec 'italic'


class root.Underline
  constructor: (editor) ->
    editor.events.on 'keydown', (event) ->
      if event.ctrlKey and event.which == 85
        event.preventDefault()
        editor.exec 'underline'
