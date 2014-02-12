class Nib.Plugins.Indent extends Nib.Plugins.Base
  validNodes: ['blockquote']
  indentParagraph: -> @exec('indent')

class Nib.Plugins.Outdent extends Nib.Plugins.Base
  validNodes: ['blockquote']
  outdentParagraph: ->
    quote = @node.querySelector 'blockquote'
    quote.outerHTML = quote.innerHTML if quote
