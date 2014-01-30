# Global Scope
root = exports ? this


class root.Indent extends BasePlugin
  @pluginName: 'indent'
  @editorMethods:
    indentParagraph: -> @exec('indent')
  validNodes: ['blockquote']


class root.Outdent extends BasePlugin
  @pluginName: 'outdent'
  @editorMethods:
    outdentParagraph: ->
      quote = @node.querySelector 'blockquote'
      quote.outerHTML = quote.innerHTML if quote
  validNodes: ['blockquote']


Editor.register(Indent, Outdent)
