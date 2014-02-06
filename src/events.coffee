# Global Scope
root = exports ? this


class root.Events
  handlers: {}

  on: (name, handler) ->
    @handlers[name] = [] unless @handlers[name]?
    @handlers[name].push handler
    this

  off: (name, handler) ->
    if @handlers[name]?
      @handlers[name] = @handlers[name].filter((fn) -> fn is not handler)
    this

  trigger: (name, args...) ->
    for fn in (@handlers[name] || [])
      fn(this, args...)
    this

  clear: () ->
    @handlers = {}
