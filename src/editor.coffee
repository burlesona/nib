# Nib Editor
#
# This is the core editor prototype. Initialize an instance
# to control a contentEditable element.

# Use Nib Utilities
_ = Nib.Utils

class Nib.Editor extends Nib.Events
  # Create a new Editor Instance
  # Requires options object be passed.
  # Requires opts.node be a dom node such as `document.getElementById('myNode')
  # Requires opts.plugins to be an array of plugin names
  # Ex:
  # myNode = document.getElementById('mynode')
  # ed = new Nib.Editor(node: myNode, plugins:['bold'])
  constructor: (opts={}) ->
    @opts = opts
    @plugins = opts.plugins || []
    @node = opts.node
    @originalClass = @node.className
    @originalContent = @node.innerHTML
    super(opts)

  # Set the given node as contenteditable
  # Create plugin instances
  # Create DOM event bindings
  # Report that the editor is on
  activate: ->
    @node.setAttribute 'contenteditable', true

    for name in @plugins
      cname = _.capitalize(name)
      this[name] = new Nib.Plugins[cname](this)

    @initDOMEvents()
    @trigger('editor:on')

  # Set the given node as not contenteditable
  # Deactivate plugin instances
  # Remove DOM event bindings
  # Report the editor is off
  # Remove all event handlers
  deactivate: () ->
    @node.setAttribute 'contenteditable', false
    this[name].deactivate() for name in @plugins
    @deactivateDOMEvents()
    @trigger('editor:off')
    @clear()

  # Detect if the node's current content is different from the original
  hasChanged: ->
    @node.innerHTML != @originalContent

  # Revert the node's content back to original
  revert: ->
    @node.innerHTML = @originalContent

  # Call browser's execCommand method on a selection
  # If arguments are given, pass them through to execCommand,
  # in this case the first argument must be a selection.
  # Otherwise, run the command against the current selection.
  exec: (command, args...) ->
    if args.length > 0
      document.execCommand(command, false, args...)
    else
      document.execCommand(command, false, @getSelection())
    @checkSelection()

  # Bind DOM Event Listeners
  initDOMEvents: ->
    @node.addEventListener 'keydown', @onKeydown.bind(@)
    @node.addEventListener 'keyup', @onKeyup.bind(@)
    @node.addEventListener 'mouseup', @onMouseup.bind(@)

  # Unbind DOM Event Listeners
  deactivateDOMEvents: ->
    @node.removeEventListener 'keydown', @onKeydown
    @node.removeEventListener 'keyup', @onKeyup
    @node.removeEventListener 'mouseup', @onMouseup

  # Trigger check selection and report keydown
  onKeydown: (event) ->
    @trigger('keydown', event)

  # Check selection on keyup
  onKeyup: (event) ->
    @checkSelection()

  # Check selection on mouse up
  onMouseup: (event) ->
    @checkSelection()

  # Use rangy to get the current selection
  getSelection: ->
    rangy.getSelection()

  # Get the current selected nodes (from current to the top of the hierarchy)
  getSelectedNodes: (selection = null) ->
    selection = selection or @getSelection()
    nodes = []
    if selection.rangeCount
      range = selection.getRangeAt(0)
      if range.collapsed
        if range.startContainer or range.endContainer
          nodes = [range.startContainer || range.endContainer]
      else
        nodes = range.getNodes()
      nodes = _.uniqueNodes(_.flatten(_.parentNodes(@node, nodes)))
      @detach(range)
    @detach(selection)
    nodes

  # Report the state of the current selection
  checkSelection: (selection = null) ->
    selection = selection or @getSelection()
    range = selection.getRangeAt(0) if selection.rangeCount
    opts =
      selection: selection
      range: range
      nodes: @getSelectedNodes(selection)
      states: []

    for name in @plugins
      opts.states.push(name) if this[name].checkSelection(opts)

    @trigger('report', opts)
    @detach(range)

  # Call detach on rangy elements to free the selection and memory
  detach: (args...) ->
    _.rangyDetach(args...)

  # Make a copy of the selection so we can restore it after transformation
  saveSelection: () ->
    new Nib.SelectionHandler()

  # Restore the selection after a transformation
  restoreSelection: (selection) ->
    selection.restoreSelection()
    @checkSelection()

  # Set the current to be the given node and fire checkSelection to notify
  # plugins and event listeners
  selectNode: (node, selection = null) ->
    selection = selection or @getSelection()
    # Update range directly in the selection, otherwise setSingleRange() will
    # reset the selection if the node is "hard" to unselect like when there's
    # no content on it
    if selection.rangeCount
      range = selection.getRangeAt(0)
      range.selectNode(node)
    else
      range = rangy.createRange()
      range.selectNodeContents(node)
      selection.setSingleRange(range)
    @checkSelection(selection)

  # Wrap current selection with a tag of type `tagName`
  wrap: (tagName, selection = null) ->
    selection = selection or @getSelection()
    range = selection.getRangeAt(0) if selection.rangeCount

    # create new wrapper node
    node = document.createElement tagName

    if range and range.canSurroundContents()
      range.surroundContents(node)

    # selection is lost in the process, reselect it
    newRange = rangy.createRange()
    newRange.selectNodeContents(node)
    selection.setSingleRange(newRange)
    @checkSelection(selection)
    @detach(range)
    node

  # Filter `nodes` looking for nodes of type `tagName`
  findTags: (tagName, nodes) ->
    tagName = tagName.toUpperCase()
    (node for node in nodes when node.nodeType == 1 and
                                 node.tagName == tagName)

  # Return the first node in `nodes` of type `tagName`
  findTag: (tagName, nodes) ->
    tagName = tagName.toUpperCase()
    for node in nodes when node.nodeType == 1
      return node if node.tagName == tagName

  # Return first wrapper of type `tagName` in current selection
  wrapped: (tagName) ->
    @findTag(tagName, @getSelectedNodes())

  # Unwrap the closes `tagName` in current selection
  unwrap: (tagName) ->
    savedSelection = @saveSelection()
    for node in @findTags(tagName, @getSelectedNodes())
      while (childNode = node.firstChild)
        # Here we must not delete & recreate nodes, we just move them. The
        # selection can't be restored when the nodes gets deleted.
        node.parentNode.insertBefore(childNode, node)
      node.remove()
    @restoreSelection(savedSelection)
    @checkSelection()
