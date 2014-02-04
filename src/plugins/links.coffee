# Global Scope
root = exports ? this

class root.Link extends BasePlugin
  @pluginName: 'link'
  @editorMethods:
    createLink: (url) -> @exec('createLink', url)
  validNodes: ['a']

class root.Link2 extends BasePlugin
  @pluginName: 'link2'
  @editorMethods:
    removeLink2: () ->
      @unwrap('a')

    createLink2: (url) ->
      url = "http://#{url}" if url.indexOf('://') is -1

      node = @wrapped('a') || @wrap('a')
      node.href = url
      node

  validNodes: ['a']

Editor.register(Link, Link2)

















































