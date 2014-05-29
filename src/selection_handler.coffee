# Use Nib Utilities
_ = Nib.Utils

# This class helps on keeping the selection when changing
# selected nodes
class Nib.SelectionHandler
  constructor: () ->
    selection = rangy.getSelection()

    if selection.rangeCount
      @range = selection.getRangeAt(0)
      @backwards = selection.isBackwards()

  restoreSelection: () ->
    if @range
      newRange = rangy.createRange()
      newRange.setStart(@range.startContainer, @range.startOffset)
      newRange.setEnd(@range.endContainer, @range.endOffset)

      selection = rangy.getSelection()
      selection.removeAllRanges()
      selection.addRange(newRange, @backwards)

  # Collapse the current selection to the end
  # ie: `|hello|` becomes `hello||`
  collapseToEnd: ->
    rangy.getSelection().collapseToEnd()

  # Collapse the current selection to the beginning
  # ie: `|hello|` becomes `||hello`
  collapseToStart: ->
    rangy.getSelection().collapseToStart()
