class Nib.Plugins.Bold extends Nib.Plugins.MetaKeyAction
  key: 66  # key: b
  validNodes: ['b', 'strong']
  toggle: -> @editor.exec('bold')

class Nib.Plugins.Italic extends Nib.Plugins.MetaKeyAction
  key: 73  # key: i
  validNodes: ['i', 'em']
  toggle: -> @editor.exec('italic')

class Nib.Plugins.Underline extends Nib.Plugins.MetaKeyAction
  key: 85  # key: u
  validNodes: ['u']
  toggle: -> @editor.exec('underline')

class Nib.Plugins.Strikethrough extends Nib.Plugins.Base
  validNodes: ['strike']
  toggle: -> @editor.exec('strikeThrough')

class Nib.Plugins.Subscript extends Nib.Plugins.Base
  validNodes: ['sub']
  toggle: -> @editor.exec('subscript')

class Nib.Plugins.Superscript extends Nib.Plugins.Base
  validNodes: ['sup']
  toggle: -> @editor.exec('superscript')

class Nib.Plugins.Bold2 extends Nib.Plugins.Base
  validNodes: ['b', 'strong']
  toggle: ->
    if @editor.wrapped('b')
      @off()
    else if @editor.wrapped('strong')
      @off('strong')
    else
      @on()
  on: -> @editor.wrap('b')
  off: (tag='b') -> @editor.unwrap(tag)
