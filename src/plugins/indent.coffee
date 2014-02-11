class Nib.Indent extends Nib.BasePlugin
  @pluginName: 'indent'
  @editorMethods:
    indentParagraph: -> @exec('indent')
  validNodes: ['blockquote']


class Nib.Outdent extends Nib.BasePlugin
  @pluginName: 'outdent'
  @editorMethods:
    outdentParagraph: ->
      quote = @node.querySelector 'blockquote'
      quote.outerHTML = quote.innerHTML if quote
  validNodes: ['blockquote']


Nib.Editor.register(Nib.Indent, Nib.Outdent)
