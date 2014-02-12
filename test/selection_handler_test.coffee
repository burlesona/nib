assert = chai.assert

describe "Nib.SelectionHandler", ->
  describe "restoreSelection", ->
    context "for <b>h|ell|o</b>", ->
      context "moving the text outside the <b>", ->
        it "restores the selection", ->
          testNodeWithSelection "<b>h|ell|o</b>", false, (root) ->
            selection = new Nib.SelectionHandler()
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
