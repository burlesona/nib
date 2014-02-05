assert = chai.assert

makeNode = (type,html) ->
  el = document.createElement(type)
  el.innerHTML = html
  document.body.appendChild(el)
  el

testNode = (type,html,callback) ->
  node = makeNode type, html
  callback(node)
  node.remove()

makeSelection = (startNode, startOffset, endNode, endOffset) ->
  range = rangy.createRange()
  range.setStart(startNode, startOffset)
  range.setEnd(endNode, endOffset)
  selection = window.getSelection()
  selection.removeAllRanges()
  selection.addRange(range.nativeRange)
  range.detach()

  selection

makeBackwardSelection = (startNode, startOffset, endNode, endOffset) ->
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

getSelectionParams = (element) ->
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

testNodeWithSelection = (html, backwards, callback) ->
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

markSelection = () ->
  selection = getSelection()
  start = selection.baseOffset
  startText = selection.baseNode.nodeValue

  startText = endText = \
    startText.slice(0, start) + "|" +
    startText.slice(start)

  if selection.baseNode is selection.extentNode
    end = selection.extentOffset + 1
  else
    selection.baseNode.nodeValue = startText
    end = selection.extentOffset
    endText = selection.extentNode.nodeValue

  endText = endText.slice(0, end) + "|" +
            endText.slice(end)

  selection.extentNode.nodeValue = endText
  selection.removeAllRanges()

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

describe "SelectionHandler", ->
  describe "restoreSelection", ->
    context "for <b>h|ell|o</b>", ->
      context "moving the text outside the <b>", ->
        it "restores the selection", ->
          testNodeWithSelection "<b>h|ell|o</b>", false, (root) ->
            selection = new SelectionHandler()
            # root is actually <p><b>hello</b></p>
            node = root.firstChild

            # move the element outside its container
            root.insertBefore(node.firstChild, node)
            # remove old container
            node.remove()

            # restore selection
            selection.restoreSelection()

            assert.equal(root.innerHTML, "hello")
            markSelection()
            assert.equal(root.innerHTML, "h|ell|o")


describe "Editor", ->
  it "should exist", ->
    assert.ok Editor

  describe "activation", ->
    it "should mark a node as contentEditable on activate", ->
      testNode 'p', 'Here is some sample text', (p) ->
        assert.equal p.contentEditable, 'inherit'
        ed = new Editor node: p
        ed.activate()
        assert.equal p.contentEditable, 'true'

  describe "transformation", ->
    it "should change a selection to bold", ->
      testNode 'p', 'Hello World', (p) ->
        ed = new Editor node: p
        ed.activate()
        s = makeSelection p.firstChild, 0, p.firstChild, 5
        ed.exec('bold',s)
        expected = "<b>Hello</b> World"
        assert.equal p.innerHTML, expected

    it "should wrap an element in custom markup", ->
      testNode 'p', 'Hello World', (p) ->
        ed = new Editor node: p, plugins: ['bold2']
        ed.activate()
        s = makeSelection p.firstChild, 0, p.firstChild, 5
        ed.toggleBold2()
        expected = "<b>Hello</b> World"
        assert.equal p.innerHTML, expected

  describe "unwrap", ->
    context "for: |h<b>el|l</b>o", ->
      it "converts to '|hel|<b>l</b>o'", ->
        testNodeWithSelection "|h<b>el|l</b>o", false, (node) ->
          ed = new Editor(node: node)

          ed.unwrap("b", true)
          assert.equal(node.innerHTML, "hel<b>l</b>o")

      it "keeps the selection", ->
        testNodeWithSelection "|h<b>el|l</b>o", false, (node) ->
          ed = new Editor(node: node)

          ed.unwrap("b", true)
          markSelection()
          assert.equal(node.innerHTML, "|hel|<b>l</b>o")

    context "for: |<b>hel|lo</b>", ->
      it "converts to hel<b>lo</b>", ->
        testNodeWithSelection "|<b>hel|lo</b>", false, (node) ->
          ed = new Editor(node: node)

          ed.unwrap("b", true)
          assert.equal(node.textContent, "hello")
          assert.equal(node.innerHTML, "hel<b>lo</b>")

      it "keeps the selection", ->
        testNodeWithSelection "<b>hel|lo</b>|", false, (node) ->
          ed = new Editor(node: node)

          ed.unwrap("b", true)
          markSelection()
          assert.equal(node.innerHTML, "<b>hel|</b>lo|")

    context "for: <b>hel|lo</b>|", ->
      it "converts to <b>hel</b>lo", ->
        testNodeWithSelection "<b>hel|lo</b>|", false, (node) ->
          ed = new Editor(node: node)

          ed.unwrap("b", true)
          assert.equal(node.innerHTML, "<b>hel</b>lo")

      it "keeps the selection", ->
        testNodeWithSelection "<b>hel|lo</b>|", false, (node) ->
          ed = new Editor(node: node)

          ed.unwrap("b", true)
          markSelection()
          assert.equal(node.innerHTML, "<b>hel|</b>lo|")

    context "for: <b>h|ell|o</b>", ->
      it "converts to <b>h</b>ell<b>o</b>", ->
        testNodeWithSelection "<b>h|ell|o</b>", false, (node) ->
          ed = new Editor(node: node)

          ed.unwrap("b", true)
          assert.equal(node.innerHTML, "<b>h</b>ell<b>o</b>")

    context "for: <b>|hello|</b>", ->
      it "converts to '|hello|'", ->
        testNodeWithSelection "<b>|hello|</b>", false, (node) ->
          ed = new Editor(node: node)

          ed.unwrap("b", true)
          assert.equal(node.innerHTML, "hello")

      it "keeps the selection", ->
        testNodeWithSelection "<b>|hello|</b>", false, (node) ->
          ed = new Editor(node: node)

          ed.unwrap("b", true)
          markSelection()
          assert.equal(node.innerHTML, "|hello|")

    context "for: |h<b>ell</b>o|", ->
      it "converts to '|hello|'", ->
        testNodeWithSelection "|h<b>ell</b>o|", false, (node) ->
          ed = new Editor(node: node)

          ed.unwrap("b", true)
          assert.equal(node.innerHTML, "hello")
          markSelection()
          assert.equal(node.innerHTML, "|hello|")


    context "for: h<b>|e</b><b>l|</b>lo", ->
      it "converts to 'h|el|lo'", ->
        testNodeWithSelection "h<b>|e</b><b>l|</b>lo", false, (node) ->
          ed = new Editor(node: node)

          ed.unwrap("b", true)
          assert.equal(node.innerHTML, "hello")
          markSelection()
          assert.equal(node.innerHTML, "h|el|lo")

    context "when text is selected backwards", ->
      context "for: h<b>|e</b><b>l|</b>lo", ->
        it "converts to 'h|el|lo'", ->
          testNodeWithSelection 'h<b>|e</b><b>l|</b>lo', true, (node) ->
            ed = new Editor(node: node)

            ed.unwrap("b", true)
            assert.equal(node.innerHTML, 'hello')
            markSelection()
            assert.equal(node.innerHTML, 'h|el|lo')
