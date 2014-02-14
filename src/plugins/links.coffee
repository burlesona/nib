class Nib.Plugins.Link extends Nib.Plugins.Base
  validNodes: ['a']

  # Create a link on the selection
  on: (url) ->
    url = "http://#{url}" if url.indexOf('://') is -1
    node = @editor.wrapped('a') || @editor.wrap('a')
    node.href = url
    node

  # Remove a link from the selection
  off: -> @editor.unwrap('a')

  # Retrieve the href to display to the user
  getHref: ->
    node.href if (node = @editor.wrapped('a'))
