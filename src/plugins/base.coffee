# Global Scope
root = exports ? this

class root.BasePlugin
  @pluginName: ''
  @editorMethods: {}

  @extendEditor: (Editor) ->
    for name, method of @editorMethods
      Editor::[name] = method

  constructor: (editor) ->
    @editor = editor
    @initEvents()

  initEvents: -> undefined

  validNode: (node) ->
    node.nodeName.toLowerCase() in @validNodes

  selectionNodes: (nodes = []) ->
    Utils.domNodes(nodes).filter @validNode.bind(@)

  checkSelection: (editor, opts = {}) ->
    nodes = @selectionNodes(opts.nodes)
    (if @selectionNodes(opts.nodes).length == 0 then '-' else '') + @constructor.pluginName

  deactivate: () -> undefined


class root.MetaKeyAction extends BasePlugin
  key: null
  method: ''

  initEvents: ->
    super()
    @editor.on 'keydown', (event, editor) =>
      if (event.ctrlKey or event.metaKey) and event.which == @key
        event.preventDefault()
        editor[@method]()
