# Global Scope
root = exports ? this


class root.Editor extends Events
  plugins: []

  constructor: (opts) ->
    @opts = opts || {}
    @node = opts.node
    @originalClass = @node.className
    @originalContent = @node.innerHTML

  activate: ->
    @node.className += ' editing'
    @node.setAttribute 'contenteditable', true
    @plugins = [new Plug(@) for Plug in @opts.plugins]
    @initEvents()

  deactivate: ->
    @node.className = @originalClass
    @node.setAttribute 'contenteditable', false

  revert: ->
    @node.innerHTML = @originalContent

  exec: (command) ->
    document.execCommand(command, false, @getSelection())

  getSelection: ->
    window.getSelection()

  initEvents: ->
    $(@node).on 'keydown', (event) =>
      @trigger('keydown', event)
