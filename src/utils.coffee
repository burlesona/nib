# Nib Utilities
#
# This Object is a namespace for utility functions
# that are used throughout the library.

Nib.Utils =
  # Capitalize a string. Ex:
  # capitalize("foobar") #=> "Foobar"
  capitalize: (string) ->
    string.charAt(0).toUpperCase() + string.slice(1)

  parentNodes: (stopNode, node) ->
    if node instanceof Array
      (@parentNodes(stopNode, n) for n in node)
    else
      parents = []
      while node and node != stopNode
        parents.push(node)
        node = node.parentNode
      parents

  flatten: (arr) ->
    if arr.length is 0 then return []
    arr.reduce (lhs, rhs) -> lhs.concat rhs

  indexOf: (col, item) ->
    i = 0
    while (i < col.length)
      return i if col[i] == item
      i += 1
    -1

  uniqueNodes: (arr) ->
    nodes = []
    for node in arr
      nodes.push(node) unless node._visited
      node._visited = true
    for node in nodes  # reset flag
      node._visited = false
    nodes

  domNodes: (nodes) ->
    nodes.filter (n) -> n.nodeType == 1

  rangyDetach: (args...) ->
    for rangyEl in args when rangyEl
      # Catch detaching errors, node could be removed from the DOM, etc, avoid
      # breaking the editor while detaching a selection, specially on IE
      try
        rangyEl.detach()
      catch err
        null
