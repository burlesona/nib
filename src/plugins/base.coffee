# Global Scope
root = exports ? this

class root.BasePlugin
  @pluginName: ''
  @editorMethods: {}

  @extendEditor: (Editor) ->
    for name, method of @editorMethods
      Editor::[name] = method

  constructor: (editor) ->
    @validNodes = []
    @editor = editor
    @initEvents()

  initEvents: ->
    @editor.on 'selection:change', (editor, selection, range, nodes, htmlContent) =>
      @checkSelection(editor, selection, range, nodes, htmlContent)

  validNode: (node) ->
    node.nodeName.toLowerCase() in @validNodes

  checkSelection: (editor, selection, range, nodes, htmlContent) ->
    nodes = Utils.domNodes(nodes).filter @validNode.bind(@)
    if nodes.length > 0
      editor.trigger("report:#{@constructor.pluginName}:on", nodes)
    else
      editor.trigger("report:#{@constructor.pluginName}:off")

  deactivate: () ->
    null


class root.MetaKeyAction extends BasePlugin
  key: null
  method: ''

  initEvents: ->
    super()
    @editor.on 'keydown', (editor, event) =>
      if (event.ctrlKey or event.metaKey) and event.which == @key
        event.preventDefault()
        editor[@method]()
