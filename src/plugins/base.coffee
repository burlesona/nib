# Nib Plugins Base
#
# Provides base plugin prototypes that other plugins can
# extend.

_ = Nib.Utils

# Base
#
# A prototype plugin defining the methods that all plugins
# must provide. All plugins should extend this prototype.
class Nib.Plugins.Base
  # Set a reference to the current editor so its
  # commands can be used, and then bind any events.
  constructor: (editor) ->
    @editor = editor
    @initEvents()

  # There are no events associated with the base prototype,
  # but plugins should define events.
  initEvents: -> undefined

  # Detect if a node represents the state of this plugin
  # For instance, a <b></b> node would be valid for a Bold plugin
  validNode: (node) ->
    node.nodeName.toLowerCase() in @validNodes

  # Find nodes that are valid for this plugin
  selectionNodes: (nodes = []) ->
    _.domNodes(nodes).filter @validNode.bind(@)

  # The editor will call this to ask each plugin if it considers
  # the current selection to contain its state. Ie, does the current
  # selection contain valid nodes for this plugin?
  # If yes, the method should return the state name that corresponds
  # to the current plugin
  checkSelection: (opts = {}) ->
    @selectionNodes(opts.nodes).length > 0

  # Perform any cleanup needed to disable this plugin, such as removing
  # DOM event bindings
  deactivate: -> undefined


# MetaKeyAction
#
# A prototype that adds bindings for keyboard shortcuts, such as `command+b`,
# or `control+b` on Windows.
class Nib.Plugins.MetaKeyAction extends Nib.Plugins.Base
  # A static instance property defining what key (in addition to the command key)
  # should trigger this plugin's toggle method.
  key: null

  # A static instance property for the name of the method that should be called
  # By default this method is `toggle`, and most plugins should use that method
  # name. However, if a plugin does something other than change the state of the
  # selection it might make sense to provide a different name.
  method: 'toggle'

  initEvents: ->
    super()
    @editor.on 'keydown', (event, editor) =>
      if (event.ctrlKey or event.metaKey) and event.which == @key
        event.preventDefault()
        editor[@method]()
