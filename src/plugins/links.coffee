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
    createLink2: (url) ->
      url = "http://#{url}" if url.indexOf('://') is -1
      console.log 'url', url
      if @wrapped('a')
        @unwrap('a')
      else
        node = @wrap('a')
        node.href = url
        node.id = "new-link"
    updateLink: (url) ->
      node = document.querySelector '#new-link'
      url = "http://#{url}" if url.indexOf('://') is -1
      node.href = url
      node.removeAttribute 'id'

  validNodes: ['a']

Editor.register(Link, Link2)

















































