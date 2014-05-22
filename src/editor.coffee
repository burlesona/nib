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

  # This function starts from a node, it travels all the way up to the root
  # node. It returns true if we can find an element with specified tag,
  # otherwise it returns false
  findBoundary: (tagName, testNode) ->
    tagName = tagName.toUpperCase()
    while (testNode != @node)
      return true if testNode.nodeType == 1 and testNode.tagName = tagName
      testNode = testNode.parentNode
    false

  # Given a text node and an offset, this function splits the parent element
  # into 2 elements, notice the original element is kept, only
  # one new element is created
  #
  # A separate argument determines whether the new element is inserted
  # to the start or the end
  splitNodeBoundary: (splitNode, offset, isStart) ->
    splitElement = splitNode.parentNode
    clonedElement = splitElement.cloneNode(true)
    clonedNode = clonedElement.firstChild
    parentElement = splitElement.parentNode
    if isStart
      clonedNode.deleteData(offset, -1)
      splitNode.deleteData(0, offset)
      parentElement.insertBefore(clonedElement, splitElement)
    else
      clonedNode.deleteData(0, offset)
      splitNode.deleteData(offset, -1)
      sibling = splitElement.nextSibling
      if sibling
        parentElement.insertBefore(clonedElement, sibling)
      else
        parentElement.appendChild(clonedElement)
    [parentElement, _.indexOf(parentElement.childNodes, splitElement)]

  # Given an HTML element(<b> for example) and an offset, split this
  # element into 2 elements, each containing part of the child nodes.
  #
  # Notice the item at offset index always belongs to the original
  # element, no matter the new element is added at front(isStart is true),
  # or at the end(isStart is false)
  splitElementBoundry: (splitElement, offset, isStart) ->
    clonedElement = splitElement.cloneNode(false)
    parentElement = splitElement.parentNode
    nodes = splitElement.childNodes
    if isStart
      clonedElement.appendChild(nodes[0]) for [1..offset] if offset
      parentElement.insertBefore(clonedElement, splitElement)
    else
      t = nodes.length - offset - 1
      clonedElement.appendChild(nodes[offset + 1]) for [1..t] if t
      sibling = splitElement.nextSibling
      if sibling
        parentElement.insertBefore(clonedElement, sibling)
      else
        parentElement.appendChild(clonedElement)
    [parentElement, _.indexOf(parentElement.childNodes, splitElement)]

  # This function starts from splitNode, it recursively splits node/element
  # into 2 nodes/elements, until one of the following 2 conditions happens:
  # 1. We've reached the root node
  # 2. We've just splitted an element with given tag name
  #
  # Notive when condition #2 is met, the element with specified node is
  # splitted, then the function will exit.
  splitBoundaryRecursive: (tagName, splitNode, offset, isStart) ->
    tagName = tagName.toUpperCase()
    loop
      return if splitNode == @node
      quitAfterSplit = (splitNode.nodeType == 1 and splitNode.tagName == tagName)
      if splitNode.nodeType == 1
        [splitNode, offset] = @splitElementBoundry(splitNode, offset, isStart)
      else
        [splitNode, offset] = @splitNodeBoundary(splitNode, offset, isStart)
      return if quitAfterSplit

  # This function checks the very start and end element of selection range.
  # If the element is partial selected, like "<b>aa|bb</b>", and the tag is
  # also the one to unwrap, the element will be split into half, like
  # "<b>aa</b><b>|bb</b>", so we can only unwrap the needed one.
  #
  # Note that this function will do the spliting recursively, so if we are
  # unwrapping <b>, and we have "<b>a<i>bb|cc|bb</i>a</b>", the result will
  # be "<b>a<i>bb</i></b><i>|cc|</i><b><i>bb</i>a</b>"
  #
  # However, if we do not find any tag to unwrap all the way up to the root,
  # the element will not be split even if it is only partial selected.
  splitBoundaries: (tagName) ->
    selection = rangy.getSelection()
    if selection.rangeCount
      range = selection.getRangeAt(0)
      if range.startContainer and @findBoundary(tagName, range.startContainer) and range.startOffset > 0
        @splitBoundaryRecursive(tagName, range.startContainer, range.startOffset, true)
        range.refresh()
      if range.endContainer and @findBoundary(tagName, range.endContainer) and range.endOffset < range.endContainer.length
        @splitBoundaryRecursive(tagName, range.endContainer, range.endOffset, false)
        range.refresh()
      @detach(range)
    @detach(selection)

  # Unwrap the closes `tagName` in current selection
  unwrap: (tagName) ->
    @splitBoundaries(tagName)
    savedSelection = @saveSelection()
    for node in @findTags(tagName, @getSelectedNodes())
      while (childNode = node.firstChild)
        # Here we must not delete & recreate nodes, we just move them. The
        # selection can't be restored when the nodes gets deleted.
        node.parentNode.insertBefore(childNode, node)
      node.remove()
    @restoreSelection(savedSelection)
    @checkSelection()
