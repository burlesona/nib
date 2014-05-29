# Global Scope
root = exports ? this

# Nib Test Helpers
root.makeNode = (type,html,append=true) ->
  el = document.createElement(type)
  el.innerHTML = html
  document.body.appendChild(el) if append
  el

root.testNode = (type,html,callback) ->
  node = makeNode type, html
  callback(node)
  node.remove()

root.makeSelection = (startNode, startOffset, endNode, endOffset) ->
  range = rangy.createRange()
  range.setStart(startNode, startOffset)
  range.setEnd(endNode, endOffset)
  selection = window.getSelection()
  selection.removeAllRanges()
  selection.addRange(range.nativeRange)
  range.detach()

  selection

root.makeBackwardSelection = (startNode, startOffset, endNode, endOffset) ->
  range = rangy.createRange()
  endRange = rangy.createRange()
  selection = rangy.getSelection()

  range.setStart(startNode, startOffset)
  range.setEnd(startNode, startOffset)

  endRange.setStart(endNode, endOffset)
  endRange.setEnd(endNode, endOffset)

  selection.addRange(range)
  selection.addRange(endRange, true)

  range.detach()
  endRange.detach()

  selection

root.getSelectionParams = (element) ->
  selection = []

  for node in element.childNodes
    if node.nodeType == 3 # text
      if (index = node.nodeValue.indexOf("|")) isnt -1
        node.nodeValue = node.nodeValue.replace("|", "")
        selection.push(node: node, index: index)

        if (index = node.nodeValue.indexOf("|")) isnt -1
          node.nodeValue = node.nodeValue.replace("|", "")
          selection.push(node: node, index: index)
    else
      selection = selection.concat(getSelectionParams(node))

  selection

root.testNodeWithSelection = (html, backwards, callback) ->
  node = makeNode("p", html)

  selection = getSelectionParams(node)

  if backwards
    makeBackwardSelection(selection[1].node, selection[1].index,
                          selection[0].node, selection[0].index)
  else
    makeSelection(selection[0].node, selection[0].index,
                  selection[1].node, selection[1].index)

  callback(node)

  node.remove()

root.markSelection = () ->
  selection = getSelection()
  if selection.rangeCount
    range = selection.getRangeAt(0)
    range.startContainer.insertData(range.startOffset, '|')
    range.endContainer.insertData(range.endOffset, '|')

before ->
  rangy.init()

# Test Helper Tests
assert = chai.assert
describe "Test Helpers", ->
  describe "makeNode", ->
    it "should create an element and append it to the dom", ->
      p = makeNode 'p','Hello World!'
      assert.equal p.nodeName, 'P'
      assert.equal p.innerText, 'Hello World!'
      assert document.body.lastChild == p
      p.remove()

  describe "testNode", ->
    it "should provide a temp node in a callback", ->
      testP = null
      testNode 'p', 'This is a test', (p) ->
        testP = p
        assert.equal document.body.lastChild, p
        assert.equal p.innerText, 'This is a test'
      assert document.body.lastChild != testP

  describe "makeSelection", ->
    it "should return a selection inside a node", ->
      testNode 'p', 'Here is a test', (p) ->
        s = makeSelection p.firstChild, 0, p.firstChild, 7
        assert.equal s.toString(), 'Here is'

  describe "getSelectionParams", ->
    context "for h|ell|o", ->
      it "remove the markers from node", ->
        testNode "p", "h|ell|o", (node) ->
          selection = getSelectionParams(node)

          assert.equal(node.innerHTML, "hello")

      it "returns the same element for start and end", ->
        testNode "p", "h|ell|o", (node) ->
          selection = getSelectionParams(node)

          assert.equal(selection[0].node, node.firstChild)
          assert.equal(selection[1].node, node.firstChild)

      it "return the positions 1 and 4", ->
        testNode "p", "h|ell|o", (node) ->
          selection = getSelectionParams(node)

          assert.equal(selection[0].index, 1)
          assert.equal(selection[1].index, 4)

    context "for <b>h|e</b>l|lo", ->
      it "remove the markers from node", ->
        testNode "p", "<b>h|e</b>l|lo", (node) ->
          selection = getSelectionParams(node)

          assert.equal(node.innerHTML, "<b>he</b>llo")

      it "returns the first b child content for start", ->
        testNode "p", "<b>h|e</b>l|lo", (node) ->
          selection = getSelectionParams(node)

          assert.equal(selection[0].node, node.querySelector("b").firstChild)

      it "returns the last element for end", ->
        testNode "p", "<b>h|e</b>l|lo", (node) ->
          selection = getSelectionParams(node)

          assert.equal(selection[1].node, node.lastChild)

      it "return the position 1 for start", ->
        testNode "p", "<b>h|e</b>l|lo", (node) ->
          selection = getSelectionParams(node)

          assert.equal(selection[0].index, 1)

      it "return the position 1 for end", ->
        testNode "p", "<b>h|e</b>l|lo", (node) ->
          selection = getSelectionParams(node)

          assert.equal(selection[1].index, 1)

  describe "testNodeWithSelection", ->
    context "backwards selection", ->
      context "for h|ell|o", ->
        it "selects ell", ->
          testNodeWithSelection "h|ell|o", true, (node) ->
            selection = rangy.getSelection()
            assert.equal(selection.toHtml(), "ell")

      context "for h|e<b>ll|o</b>", ->
        it "selects e<b>ll</b>", ->
          testNodeWithSelection "h|e<b>ll|o</b>", true, (node) ->
            selection = rangy.getSelection()

            assert.equal(selection.toHtml(), "e<b>ll</b>")

    context "for h|ell|o", ->
      it "creates a hello", ->
        testNodeWithSelection "h|ell|o", false, (node) ->

          assert.equal(node.innerHTML, "hello")

      it "selects ell", ->
        testNodeWithSelection "h|ell|o", false, (node) ->
          selection = rangy.getSelection()

          assert.equal(selection.toHtml(), "ell")

     context "for h|e<b>ll|o</b>", ->
      it "creates a he<b>llo</b> node", ->
        testNodeWithSelection "h|e<b>ll|o</b>", false, (node) ->

          assert.equal(node.innerHTML, "he<b>llo</b>")

      it "selects e<b>ll</b>", ->
        testNodeWithSelection "h|e<b>ll|o</b>", false, (node) ->
          selection = rangy.getSelection()

          assert.equal(selection.toHtml(), "e<b>ll</b>")

  describe "markSelection", ->
    it "adds marks to h|ell|o", ->
      testNodeWithSelection "h|ell|o", false, (node) ->

        markSelection()

        assert.equal(node.innerHTML, "h|ell|o")

    it "adds marks to h|e<b>ll|o</b>", ->
      testNodeWithSelection "h|e<b>ll|o</b>", false, (node) ->

        markSelection()

        assert.equal(node.innerHTML, "h|e<b>ll|o</b>")
