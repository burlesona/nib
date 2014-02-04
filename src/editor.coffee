# Global Scope
root = exports ? this

class root.Editor extends Events
  @pluginsRegistry: {}

  @register: (plugins...) ->
    for Plugin in plugins
      @pluginsRegistry[Plugin.pluginName] = Plugin
      Plugin.extendEditor(@)

  constructor: (opts) ->
    @opts = opts || {}
    @node = opts.node
    @originalClass = @node.className
    @originalContent = @node.innerHTML

  activate: (callback) ->
    @node.setAttribute 'contenteditable', true
    @plugins = (new Editor.pluginsRegistry[name](@) for name in @opts.plugins) if @opts.plugins?
    @initDOMEvents()
    callback this if callback?

  deactivate: (callback) ->
    @node.setAttribute 'contenteditable', false
    plugin.deactivate() for plugin in @plugins if @plugins
    @deactivateDOMEvents()
    @clear()
    callback this if callback?

  hasChanged: ->
    @node.innerHTML != @originalContent

  revert: ->
    @node.innerHTML = @originalContent

  exec: (command, args...) ->
    if args.length > 0
      document.execCommand(command, false, args...)
    else
      document.execCommand(command, false, @getSelection())
    @checkSelection()

  initDOMEvents: ->
    @node.addEventListener 'keydown', @onKeydown.bind(@)
    @node.addEventListener 'keyup', @onKeyup.bind(@)
    @node.addEventListener 'mousedown', @onMousedown.bind(@)
    @node.addEventListener 'mouseup', @onMouseup.bind(@)

  deactivateDOMEvents: ->
    @node.removeEventListener 'keydown', @onKeydown
    @node.removeEventListener 'keyup', @onKeyup
    @node.removeEventListener 'mousedown', @onMousedown
    @node.removeEventListener 'mouseup', @onMouseup

  onKeydown: (event) ->
    @checkSelection()
    @trigger('keydown', event)

  onKeyup: (event) ->
    @checkSelection()

  onMousedown: (event) ->
    @checkSelection()

  onMouseup: (event) ->
    @checkSelection()

  getSelection: ->
    rangy.getSelection()

  getSelectedNodes: () ->
    selection = @getSelection()
    nodes = []
    if selection.rangeCount
      range = selection.getRangeAt(0)
      if range.collapsed
        if range.startContainer or range.endContainer
          nodes = [range.startContainer || range.endContainer]
      else
        nodes = range.getNodes()
      nodes = Utils.uniqueNodes(Utils.flatten(Utils.parentNodes(@node, nodes)))
      range.detach()

    selection.detach()
    nodes

  checkSelection: () ->
    nodes = @getSelectedNodes()
    selection = @getSelection()
    range = selection.getRangeAt(0) if selection.rangeCount

    @trigger('selection:change', selection, range, nodes, selection.toHtml())
    @detach(selection, range)

  detach: (args...) ->
    rangyEl.detach() for rangyEl in args when rangyEl

  saveSelection: () ->
    new SelectionHandler()

  restoreSelection: (selection) ->
    selection.restoreSelection()
    @checkSelection()

  selectElement: (element) ->
    range = rangy.createRange()
    range.selectNodeContents(element)

    selection = @getSelection()
    selection.setSingleRange(range)

  wrap: (tagName) ->
    selection = @getSelection()
    range = selection.getRangeAt(0)

    # create new wrapper node
    node = document.createElement tagName

    if range.canSurroundContents()
      range.surroundContents(node)

    # selection is lost in the process, reselect it
    newRange = rangy.createRange()
    newRange.selectNodeContents(node)
    selection.setSingleRange(newRange)
    @checkSelection()

    @detach(range)
    node

  lookForTags: (tagName, nodes) ->
    tags = []
    for node in nodes when node.nodeType == 1
      if node.tagName.toLowerCase() == tagName
        tags.push(node)
    tags

  lookForTag: (tagName, nodes) ->
    for node in nodes when node.nodeType == 1
      return node if node.tagName.toLowerCase() == tagName

  wrapped: (tagName) ->
    nodes = @getSelectedNodes()

    @lookForTag(tagName, nodes)

  unwrap: (tagName) ->
    nodes = @getSelectedNodes()
    tags = @lookForTags(tagName, nodes)

    savedSelection = @saveSelection()

    for node in tags
      while (childNode = node.firstChild)
        # Here we must not delete & recreate nodes,
        # we just move them. The selection can't be
        # restored when the nodes gets deleted.
        node.parentNode.insertBefore(childNode, node)

      node.remove()

    @restoreSelection(savedSelection)

    @checkSelection()
