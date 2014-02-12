class Nib.Plugins.Link extends Nib.Plugins.Base
  validNodes: ['a']
  toggle: (url) -> @editor.exec('createLink', url)

class Nib.Plugins.Link2 extends Nib.Plugins.Base
  validNodes: ['a']
  off: () ->
    @editor.unwrap('a')
  on: (url) ->
    url = "http://#{url}" if url.indexOf('://') is -1

    node = @editor.wrapped('a') || @editor.wrap('a')
    node.href = url
    node
