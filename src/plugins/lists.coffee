# Global Scope
root = exports ? this


class root.UnorderedList
  constructor: (editor) ->
    @editor = editor
    @editor.on 'unordered-list', () =>
      @editor.exec 'insertUnorderedList'


class root.OrderedList
  constructor: (editor) ->
    @editor = editor
    @editor.on 'ordered-list', () =>
      @editor.exec 'insertOrderedList'
