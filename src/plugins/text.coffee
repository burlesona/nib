# Global Scope
root = exports ? this


class root.BoldText extends MetaKeyAction
  @editorMethods: toggleBold: -> @exec('bold')
  key: 66  # key: b
  method: 'toggleBold'
  onEventName: 'report:bold:on'
  offEventName: 'report:bold:off'
  validNode: (node) ->
    node.nodeName == 'B' || node.nodeName == 'STRONG'


class root.ItalicText extends MetaKeyAction
  @editorMethods: toggleItalic: -> @exec('italic')
  key: 73  # key: i
  method: 'toggleItalic'
  onEventName: 'report:italic:on'
  offEventName: 'report:italic:off'
  validNode: (node) ->
    node.nodeName == 'I'


class root.Underline extends MetaKeyAction
  @editorMethods: toggleUnderline: -> @exec('underline')
  key: 85  # key: u
  method: 'toggleUnderline'
  onEventName: 'report:underline:on'
  offEventName: 'report:underline:off'
  validNode: (node) ->
    node.nodeName == 'U'


class root.StrikeThrough extends BasePlugin
  @editorMethods: toggleStrikeThrough: -> @exec('strikeThrough')
  onEventName: 'report:strikethrough:on'
  offEventName: 'report:strikethrough:off'
  validNode: (node) ->
    node.nodeName == 'STRIKE'


class root.Subscript extends BasePlugin
  @editorMethods: toggleSubscript: -> @exec('subscript')
  onEventName: 'report:subscript:on'
  offEventName: 'report:subscript:off'
  validNode: (node) ->
    node.nodeName == 'SUB'


class root.Superscript extends BasePlugin
  @editorMethods: toggleSuperscript: -> @exec('superscript')
  onEventName: 'report:superscript:on'
  offEventName: 'report:superscript:off'
  validNode: (node) ->
    node.nodeName == 'SUP'


Editor.register(BoldText, ItalicText, Underline,
                StrikeThrough, Subscript, Superscript)
