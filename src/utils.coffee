class Nib.Utils
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
