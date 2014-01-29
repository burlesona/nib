assert = chai.assert;

makeNode = (type,html) ->
  el = document.createElement(type)
  el.contentEditable = true
  el.innerHTML = html
  document.body.appendChild(el)
  el

removeNode = (node) ->
  node.parentNode.removeChild(node)

describe "Test Helpers", ->
  describe "makeNode", ->
    it "should create an element and append it to the dom", ->
      p = makeNode 'p','Hello World!'
      assert.equal p.nodeName, 'P'
      assert.equal p.innerText, 'Hello World!'
      assert document.body.lastChild == p
      removeNode p

    it "should remove an element", ->
      p = makeNode 'p', 'Hello World'
      removeNode p
      assert document.body.lastChild != p


describe "Editor", ->
  it "should exist", ->
    assert.ok Editor

  describe "activation", ->
    it "should mark a node as contentEditable on activate", ->
      node = document.createElement 'p'
      node.innerText = 'Here is some sample text'
      ed = new Editor node: node
      ed.activate()
      assert.equal node.contentEditable, 'true'

  describe "transformation", ->
    it "should change a selection to bold", ->
      p = makeNode 'p', 'Hello World'
      ed = new Editor node: p
      r = document.createRange()
      r.setStart(p.firstChild,0)
      r.setEnd(p.firstChild,5)
      s = window.getSelection()
      s.removeAllRanges()
      s.addRange(r)
      ed.exec('bold',s)
      expected = "<b>Hello</b> World"
      assert.equal p.innerHTML, expected

