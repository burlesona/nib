# This class helps on keeping the selection when changing
# selected nodes
class Nib.SelectionHandler
  constructor: () ->
    @selection = rangy.getSelection()

    @baseNode = @selection.nativeSelection.baseNode
    @baseOffset = @selection.nativeSelection.baseOffset
    @extentNode = @selection.nativeSelection.extentNode
    @extentOffset = @selection.nativeSelection.extentOffset

    @backwards = @selection.isBackwards()

  restoreSelection: () ->
    startRange = rangy.createRange()

    startRange.setStart(@baseNode, @baseOffset)
    @selection.removeAllRanges()

    if @backwards
      startRange.setEnd(@baseNode, @baseOffset)

      endRange = rangy.createRange()
      endRange.setStart(@extentNode, @extentOffset)
      endRange.setEnd(@extentNode, @extentOffset)

      @selection.addRange(startRange)
      @selection.addRange(endRange, true)

      @detach(endRange)
    else
      startRange.setEnd(@extentNode, @extentOffset)
      @selection.setSingleRange(startRange)

    @detach(startRange)

  # Collapse the current selection to the end
  # ie: `|hello|` becomes `hello||`
  collapseToEnd: ->
    @selection.collapseToEnd()

  # Collapse the current selection to the beginning
  # ie: `|hello|` becomes `||hello`
  collapseToStart: ->
    @selection.collapseToStart()

  # Call detach on rangy elements to free the selection and memory
  detach: (args...) ->
    for rangyEl in args when rangyEl
      # Catch detaching errors, node could be removed from the DOM, etc, avoid
      # breaking the editor while detaching a selection
      try
        rangyEl.detach()
      catch err
        null
