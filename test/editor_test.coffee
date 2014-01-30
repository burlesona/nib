assert = chai.assert;

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
  r = document.createRange()
  r.setStart(startNode,startOffset)
  r.setEnd(endNode,endOffset)
  s = window.getSelection()
  s.removeAllRanges()
  s.addRange(r)
  s

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

