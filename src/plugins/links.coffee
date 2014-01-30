# Global Scope
root = exports ? this


class root.Link extends BasePlugin
  @pluginName: 'link'
  @editorMethods:
    createLink: (url) -> @exec('createLink', url)
  validNodes: ['a']


Editor.register(Link)
