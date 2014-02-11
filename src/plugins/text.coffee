class Nib.BoldText extends Nib.MetaKeyAction
  @pluginName: 'bold'
  @editorMethods: toggleBold: -> @exec('bold')
  key: 66  # key: b
  method: 'toggleBold'
  validNodes: ['b', 'strong']


class Nib.ItalicText extends Nib.MetaKeyAction
  @pluginName: 'italic'
  @editorMethods: toggleItalic: -> @exec('italic')
  key: 73  # key: i
  method: 'toggleItalic'
  validNodes: ['i', 'em']


class Nib.Underline extends Nib.MetaKeyAction
  @pluginName: 'underline'
  @editorMethods: toggleUnderline: -> @exec('underline')
  key: 85  # key: u
  method: 'toggleUnderline'
  validNodes: ['u']


class Nib.StrikeThrough extends Nib.BasePlugin
  @pluginName: 'strikethrough'
  @editorMethods: toggleStrikeThrough: -> @exec('strikeThrough')
  validNodes: ['strike']


class Nib.Subscript extends Nib.BasePlugin
  @pluginName: 'subscript'
  @editorMethods: toggleSubscript: -> @exec('subscript')
  validNodes: ['sub']


class Nib.Superscript extends Nib.BasePlugin
  @pluginName: 'superscript'
  @editorMethods: toggleSuperscript: -> @exec('superscript')
  validNodes: ['sup']


class Nib.BoldText2 extends Nib.BasePlugin
  @pluginName: 'bold2'
  @editorMethods:
    toggleBold2: ->
      if @wrapped('b')
        @unwrap('b')
      else if @wrapped('strong')
        @unwrap('strong')
      else
        @wrap('b')
  validNodes: ['b', 'strong']


Nib.Editor.register(Nib.BoldText, Nib.ItalicText, Nib.Underline,
                Nib.StrikeThrough, Nib.Subscript, Nib.Superscript,
                Nib.BoldText2)
