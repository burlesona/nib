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

      endRange.detach()
    else
      startRange.setEnd(@extentNode, @extentOffset)
      @selection.setSingleRange(startRange)

    startRange.detach()
