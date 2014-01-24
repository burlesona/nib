# Global Scope
root = exports ? this

class root.Utils
  @parentNodes: (stopNode, node) ->
    if node instanceof Array
      (@parentNodes(stopNode, n) for n in node)
    else
      parents = []
      while node and node != stopNode
        parents.push(node)
        node = node.parentNode
      parents

  @flatten: (arr) ->
    if arr.length is 0 then return []
    arr.reduce (lhs, rhs) -> lhs.concat rhs

  @uniqueNodes: (arr) ->
    nodes = []
    for node in arr
      nodes.push(node) unless node._visited
      node._visited = true
    for node in nodes  # reset flag
      node._visited = false
    nodes

  @domNodes: (nodes) ->
    nodes.filter (n) -> n.nodeType == 1


class root.Editor extends Events
  @pluginsRegistry: {}

  @register: (plugins...) ->
    for Plugin in plugins
      @pluginsRegistry[Plugin.name] = Plugin
      Plugin.extendEditor(@)

  constructor: (opts) ->
    @opts = opts || {}
    @node = opts.node
    @originalClass = @node.className
    @originalContent = @node.innerHTML

  activate: ->
    @node.className += ' editing'
    @node.setAttribute 'contenteditable', true
    @plugins = (new Editor.pluginsRegistry[name](@) for name in @opts.plugins)
    @initEvents()

  deactivate: ->
    @node.className = @originalClass
    @node.setAttribute 'contenteditable', false

  revert: ->
    @node.innerHTML = @originalContent

  exec: (command) ->
    document.execCommand(command, false, @getSelection())
    @checkSelection()

  getSelection: ->
    rangy.getSelection()

  initEvents: ->
    @node.addEventListener 'keydown', (event) =>
      @checkSelection()
      @trigger('keydown', event)
    @node.addEventListener 'keyup', (event) =>
      @checkSelection()
    @node.addEventListener 'mousedown', (event) =>
      @checkSelection()
    @node.addEventListener 'mouseup', (event) =>
      @checkSelection()

  checkSelection: () ->
    selection = @getSelection()
    range = null
    nodes = []
    if selection.rangeCount
      range = selection.getRangeAt(0)
      if range.collapsed
        if range.startContainer or range.endContainer
          nodes = [range.startContainer || range.endContainer]
      else
        nodes = range.getNodes()
      nodes = Utils.uniqueNodes(Utils.flatten(Utils.parentNodes(@node, nodes)))
    @trigger('selection:change', selection, range, nodes, selection.toHtml())
