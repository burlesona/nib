assert = chai.assert;

describe 'Editor', ->
  it "should exist", ->
    assert.ok Editor

  describe 'activation', ->
    it "should mark a node as contenteditable on activate", ->
      node = document.createElement 'p'
      node.innerText = 'Here is some sample text'
      ed = new Editor node: node
      ed.activate()
      assert.equal node.contentEditable, 'true'
