# Global Scope
root = exports ? this


class root.Link extends BasePlugin
  @pluginName: 'link'
  @editorMethods:
    createLink: (url) -> @exec('createLink', url)
  onEventName: 'report:link:on'
  offEventName: 'report:link:off'
  validNode: (node) ->
    node.nodeName == 'A'


Editor.register(Link)
