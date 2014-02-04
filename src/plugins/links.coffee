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
    removeLink2: (link) ->
      @selectElement(link)
      @unwrap('a')

    createLink2: (url) ->
      url = "http://#{url}" if url.indexOf('://') is -1
      if @wrapped('a')
        @unwrap('a')
      else
        node = @wrap('a')
        node.href = url
        node

    updateLink: (link, url) ->
      url = "http://#{url}" if url.indexOf('://') is -1
      link.href = url

  validNodes: ['a']

Editor.register(Link, Link2)

















































