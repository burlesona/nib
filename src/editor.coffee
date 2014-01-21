# Global Scope
root = exports ? this

class root.Editor
  constructor: (node) ->
    @node = node
    @originalClass = node.className
    @originalContent = node.innerHTML

  activate: ->
    @node.className += ' editing'
    @node.setAttribute 'contenteditable', true

  deactivate: ->
    @node.className = @originalClass
    @node.setAttribute 'contenteditable', false

  revert: -> @node.innerHTML = @originalContent
