assert = chai.assert

makeNode = (type,html) ->
  el = document.createElement(type)
  el.innerHTML = html
  document.body.appendChild(el)
  el

removeNode = (node) ->
  node.parentNode.removeChild(node)

testNode = (type,html,callback) ->
  node = makeNode type, html
  callback(node)
  removeNode node

makeSelection = (startNode,startOffset,endNode,endOffset) ->
  r = rangy.createRange()
  r.setStart(startNode,startOffset)
  r.setEnd(endNode,endOffset)
  s = window.getSelection()
  s.removeAllRanges()
  s.addRange(r.nativeRange)
  s

makeSelected = (html, backwards = false) ->
  root = makeNode('p', html)
  selection = []

  parseSelection = (element) ->
    for node in element.childNodes
      if node.nodeType == 3 # text
        if (index = node.nodeValue.indexOf("|")) isnt -1
          node.nodeValue = node.nodeValue.replace("|", "")
          selection.push(node: node, index: index)

          if (index = node.nodeValue.indexOf("|")) isnt -1
            node.nodeValue = node.nodeValue.replace("|", "")
            selection.push(node: node, index: index)
      else
        parseSelection(node)

  parseSelection(root)

  range = rangy.createRange()
  selectionObj = rangy.getSelection()

  if backwards
    range.setStart(selection[1].node, selection[1].index)
    range.setEnd(selection[1].node, selection[1].index)

    endRange = rangy.createRange()
    endRange.setStart(selection[0].node, selection[0].index)
    endRange.setEnd(selection[0].node, selection[0].index)

    selectionObj.addRange(range)
    selectionObj.addRange(endRange, true)

    endRange.detach()
  else
    range.setStart(selection[0].node, selection[0].index)
    range.setEnd(selection[1].node, selection[1].index)

    selectionObj.setSingleRange(range)

  range.detach()

  root

dumpSelection = () ->
  selection = getSelection()
  start = selection.baseOffset
  startText = selection.baseNode.nodeValue

  startText = endText = \
    startText.slice(0, start) + '|' +
    startText.slice(start)

  if selection.baseNode is selection.extentNode
    end = selection.extentOffset + 1
  else
    selection.baseNode.nodeValue = startText
    end = selection.extentOffset
    endText = selection.extentNode.nodeValue

  endText = \
    endText.slice(0, end) + '|' +
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
      removeNode p

  describe "removeNode", ->
    it "should remove an element", ->
      p = makeNode 'p', 'Hello World'
      removeNode p
      assert document.body.lastChild != p

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

  describe "makeSelected", ->
    context "backwards selection", ->
      context "for h|ell|o", ->
        it "selects ell", ->
          node = makeSelected("h|ell|o", true)
          selection = rangy.getSelection()
          assert.equal(selection.toHtml(), "ell")
          node.remove()

      context "for h|e<b>ll|o</b>", ->
        it "selects e<b>ll</b>", ->
          node = makeSelected("h|e<b>ll|o</b>", true)
          selection = rangy.getSelection()

          assert.equal(selection.toHtml(), "e<b>ll</b>")
          node.remove()

    context "for h|ell|o", ->
      it "creates a hello", ->
        node = makeSelected("h|ell|o")

        assert.equal(node.innerHTML, "hello")
        node.remove()

      it "selects ell", ->
        node = makeSelected("h|ell|o")
        selection = rangy.getSelection()

        assert.equal(selection.toHtml(), "ell")
        node.remove()

     context "for h|e<b>ll|o</b>", ->
      it "creates a he<b>llo</b> node", ->
        node = makeSelected("h|e<b>ll|o</b>")

        assert.equal(node.innerHTML, "he<b>llo</b>")
        node.remove()

      it "selects e<b>ll</b>", ->
        node = makeSelected("h|e<b>ll|o</b>")
        selection = rangy.getSelection()

        assert.equal(selection.toHtml(), "e<b>ll</b>")
        node.remove()

  describe "dumpSelection", ->
    it "adds marks to h|ell|o", ->
      node = makeSelected("h|ell|o")

      dumpSelection()

      assert.equal(node.innerHTML, "h|ell|o")
      node.remove()

    it "adds marks to h|e<b>ll|o</b>", ->
      node = makeSelected("h|e<b>ll|o</b>")

      dumpSelection()

      assert.equal(node.innerHTML, "h|e<b>ll|o</b>")
      node.remove()

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
    context "for: <b>|hello|</b>", ->
      it "converts to '|hello|'", ->
        p = makeSelected('<b>|hello|</b>')
        ed = new Editor(node: p)

        ed.unwrap('b')
        assert.equal(p.textContent, 'hello')
        dumpSelection()
        assert.equal(p.innerHTML, '|hello|')
        p.remove()

    context "for: |h<b>ell</b>o|", ->
      it "converts to '|hello|'", ->
        p = makeSelected('|h<b>ell</b>o|')
        ed = new Editor(node: p)

        ed.unwrap('b')
        assert.equal(p.innerHTML, 'hello')
        dumpSelection()
        assert.equal(p.innerHTML, '|hello|')
        p.remove()

    context "for: |h<b>el|l</b>o", ->
      it "converts to '|hel|lo'", ->
        p = makeSelected('|h<b>el|l</b>o')
        ed = new Editor(node: p)

        ed.unwrap('b')
        assert.equal p.innerHTML, 'hello'
        dumpSelection()
        assert.equal(p.innerHTML, '|hel|lo')
        p.remove()

    context "for: h<b>|e</b><b>l|</b>lo", ->
      it "converts to 'h|el|lo'", ->
        p = makeSelected('h<b>|e</b><b>l|</b>lo')
        ed = new Editor(node: p)

        ed.unwrap('b')
        assert.equal p.innerHTML, 'hello'
        dumpSelection()
        assert.equal(p.innerHTML, 'h|el|lo')
        p.remove()
