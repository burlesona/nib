class Nib.Link extends Nib.BasePlugin
  @pluginName: 'link'
  @editorMethods:
    createLink: (url) -> @exec('createLink', url)
  validNodes: ['a']

class Nib.Link2 extends Nib.BasePlugin
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

Nib.Editor.register(Nib.Link, Nib.Link2)
