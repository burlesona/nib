class Nib.BasePlugin
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
    Nib.Utils.domNodes(nodes).filter @validNode.bind(@)

  checkSelection: (editor, opts = {}) ->
    nodes = @selectionNodes(opts.nodes)
    @constructor.pluginName if @selectionNodes(opts.nodes).length > 0

  deactivate: () -> undefined


class Nib.MetaKeyAction extends Nib.BasePlugin
  key: null
  method: ''

  initEvents: ->
    super()
    @editor.on 'keydown', (event, editor) =>
      if (event.ctrlKey or event.metaKey) and event.which == @key
        event.preventDefault()
        editor[@method]()
