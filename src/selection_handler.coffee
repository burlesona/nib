# Use Nib Utilities
_ = Nib.Utils

# This class helps on keeping the selection when changing
# selected nodes
class Nib.SelectionHandler
  constructor: () ->
    @selection = rangy.getSelection()

    @anchorNode = @selection.anchorNode
    @anchorOffset = @selection.anchorOffset
    @focusNode = @selection.focusNode
    @focusOffset = @selection.focusOffset

    @backwards = @selection.isBackwards()

  restoreSelection: () ->
    startRange = rangy.createRange()

    startRange.setStart(@anchorNode, @anchorOffset)
    @selection = rangy.getSelection() if @selection.anchorNode is null
    @selection.removeAllRanges() if @selection.rangeCount

    if @backwards
      startRange.setEnd(@anchorNode, @anchorOffset)

      endRange = rangy.createRange()
      endRange.setStart(@focusNode, @focusOffset)
      endRange.setEnd(@focusNode, @focusOffset)

      @selection.addRange(startRange)
      @selection.addRange(endRange, true)

      _.rangyDetach(endRange)
    else
      startRange.setEnd(@focusNode, @focusOffset)
      @selection.setSingleRange(startRange)

    _.rangyDetach(startRange)

  # Collapse the current selection to the end
  # ie: `|hello|` becomes `hello||`
  collapseToEnd: ->
    @selection.collapseToEnd()

  # Collapse the current selection to the beginning
  # ie: `|hello|` becomes `||hello`
  collapseToStart: ->
    @selection.collapseToStart()
