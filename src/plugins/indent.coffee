class Nib.Plugins.Indent extends Nib.Plugins.Base
  validNodes: ['blockquote']
  toggle: -> @editor.exec('indent')

class Nib.Plugins.Outdent extends Nib.Plugins.Base
  validNodes: ['blockquote']
  toggle: ->
    quote = @editor.node.querySelector 'blockquote'
    quote.outerHTML = quote.innerHTML if quote
