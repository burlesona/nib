# Global Scope
root = exports ? this


class root.Indent extends BasePlugin
  @pluginName: 'indent'
  @editorMethods:
    indentParagraph: -> @exec('indent')
  validNode: (node) ->
    node.nodeName == 'BLOCKQUOTE'

class root.Outdent extends BasePlugin
  @pluginName: 'outdent'
  @editorMethods:
    outdentParagraph: ->
      quote = @node.querySelector 'blockquote'
      quote.outerHTML = quote.innerHTML if quote
  validNode: (node) ->
    node.nodeName == 'BLOCKQUOTE'


Editor.register(Indent, Outdent)
