# Global Scope
root = exports ? this


class root.BoldText extends MetaKeyAction
  @pluginName: 'bold'
  @editorMethods: toggleBold: -> @exec('bold')
  key: 66  # key: b
  method: 'toggleBold'
  onEventName: 'report:bold:on'
  offEventName: 'report:bold:off'
  validNode: (node) ->
    node.nodeName == 'B' || node.nodeName == 'STRONG'


class root.ItalicText extends MetaKeyAction
  @pluginName: 'italic'
  @editorMethods: toggleItalic: -> @exec('italic')
  key: 73  # key: i
  method: 'toggleItalic'
  onEventName: 'report:italic:on'
  offEventName: 'report:italic:off'
  validNode: (node) ->
    node.nodeName == 'I' || node.nodeName == 'EM'


class root.Underline extends MetaKeyAction
  @pluginName: 'underline'
  @editorMethods: toggleUnderline: -> @exec('underline')
  key: 85  # key: u
  method: 'toggleUnderline'
  onEventName: 'report:underline:on'
  offEventName: 'report:underline:off'
  validNode: (node) ->
    node.nodeName == 'U'


class root.StrikeThrough extends BasePlugin
  @pluginName: 'strikethrough'
  @editorMethods: toggleStrikeThrough: -> @exec('strikeThrough')
  onEventName: 'report:strikethrough:on'
  offEventName: 'report:strikethrough:off'
  validNode: (node) ->
    node.nodeName == 'STRIKE'


class root.Subscript extends BasePlugin
  @pluginName: 'subscript'
  @editorMethods: toggleSubscript: -> @exec('subscript')
  onEventName: 'report:subscript:on'
  offEventName: 'report:subscript:off'
  validNode: (node) ->
    node.nodeName == 'SUB'


class root.Superscript extends BasePlugin
  @pluginName: 'superscript'
  @editorMethods: toggleSuperscript: -> @exec('superscript')
  onEventName: 'report:superscript:on'
  offEventName: 'report:superscript:off'
  validNode: (node) ->
    node.nodeName == 'SUP'


Editor.register(BoldText, ItalicText, Underline,
                StrikeThrough, Subscript, Superscript)
