# Global Scope
root = exports ? this


class root.BoldText extends MetaKeyAction
  @pluginName: 'bold'
  @editorMethods: toggleBold: -> @exec('bold')
  key: 66  # key: b
  method: 'toggleBold'
  validNodes: ['b', 'strong']


class root.ItalicText extends MetaKeyAction
  @pluginName: 'italic'
  @editorMethods: toggleItalic: -> @exec('italic')
  key: 73  # key: i
  method: 'toggleItalic'
  validNodes: ['i', 'em']


class root.Underline extends MetaKeyAction
  @pluginName: 'underline'
  @editorMethods: toggleUnderline: -> @exec('underline')
  key: 85  # key: u
  method: 'toggleUnderline'
  validNodes: ['u']


class root.StrikeThrough extends BasePlugin
  @pluginName: 'strikethrough'
  @editorMethods: toggleStrikeThrough: -> @exec('strikeThrough')
  validNodes: ['strike']


class root.Subscript extends BasePlugin
  @pluginName: 'subscript'
  @editorMethods: toggleSubscript: -> @exec('subscript')
  validNodes: ['sub']


class root.Superscript extends BasePlugin
  @pluginName: 'superscript'
  @editorMethods: toggleSuperscript: -> @exec('superscript')
  validNodes: ['sup']


Editor.register(BoldText, ItalicText, Underline,
                StrikeThrough, Subscript, Superscript)
