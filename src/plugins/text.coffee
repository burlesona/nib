class Nib.Plugins.Bold extends Nib.Plugins.MetaKeyAction
  name: 'bold'
  key: 66  # key: b
  validNodes: ['b', 'strong']
  toggle: -> @editor.exec('bold')

class Nib.Plugins.Italic extends Nib.Plugins.MetaKeyAction
  name: 'italic'
  key: 73  # key: i
  validNodes: ['i', 'em']
  toggle: -> @editor.exec('italic')

class Nib.Plugins.Underline extends Nib.Plugins.MetaKeyAction
  name: 'underline'
  key: 85  # key: u
  validNodes: ['u']
  toggle: -> @editor.exec('underline')

class Nib.Plugins.Strikethrough extends Nib.Plugins.Base
  validNodes: ['strike']
  toggle: -> @editor.exec('strikeThrough')

class Nib.Plugins.Subscript extends Nib.Plugins.Base
  validNodes: ['sub']
  toggle: ->
    if @editor.wrapped('sup')   # sub/sup are mutually exclusive
      @editor.unwrap('sup')
    if @editor.wrapped('sub')
      @editor.unwrap('sub')
    else
      @editor.wrap('sub')

class Nib.Plugins.Superscript extends Nib.Plugins.Base
  validNodes: ['sup']
  toggle: ->
    if @editor.wrapped('sub')   # sub/sup are mutually exclusive
      @editor.unwrap('sub')
    if @editor.wrapped('sup')
      @editor.unwrap('sup')
    else
      @editor.wrap('sup')

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
