# Nib.Events
#
# Nib Events is a simple prototype that other objects can extend.
# The prototype defined basic event binding similar to jQuery's
# .on(), .off(), and .trigger()

class Nib.Events

  # Classes extending events should call super if they override the
  # constructor.
  constructor: ->
    @handlers = {}

  # Attach a handler function to an event. Ex:
  # object.on 'eventName', fn
  on: (name, handler) ->
    @handlers[name] = [] unless @handlers[name]?
    @handlers[name].push handler
    this

  # Remove a handler function from an event. Ex:
  # object.off 'eventName', fn
  off: (name, handler) ->
    if @handlers[name]?
      @handlers[name] = @handlers[name].filter((fn) -> fn is not handler)
    this

  # Trigger an event. Arguements after event name will
  # be passed through to the hanlder function. Ex:
  # object.trigger 'eventName', arguments
  trigger: (name, args...) ->
    return unless @handlers[name]
    fn(args..., this) for fn in @handlers[name]
    this

  # Remove references to all handler functions, effectively
  # unbinding any events from the object. Ex:
  # object.clear
  clear: () ->
    @handlers = {}
