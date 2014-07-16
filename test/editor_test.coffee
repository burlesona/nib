assert = chai.assert

describe "Nib.Editor", ->
  it "should exist", ->
    assert.ok Nib.Editor

  describe "activation", ->
    it "should mark a node as contentEditable on activate", ->
      testNode 'p', 'Here is some sample text', (p) ->
        assert.equal p.contentEditable, 'inherit'
        ed = new Nib.Editor node: p
        ed.activate()
        assert.equal p.contentEditable, 'true'

  describe "transformation", ->
    it "should change a selection to bold", ->
      testNode 'p', 'Hello World', (p) ->
        ed = new Nib.Editor node: p
        ed.activate()
        s = makeSelection p.firstChild, 0, p.firstChild, 5
        ed.exec('bold',s)
        expected = "<b>Hello</b> World"
        assert.equal p.innerHTML, expected

    it "should wrap an element in custom markup", ->
      testNode 'p', 'Hello World', (p) ->
        ed = new Nib.Editor node: p, plugins: ['bold2']
        ed.activate()
        s = makeSelection p.firstChild, 0, p.firstChild, 5
        ed.bold2.toggle()
        expected = "<b>Hello</b> World"
        assert.equal p.innerHTML, expected

  describe "getSelectedNodes", ->
    it "returns nodes within selection", ->
      testNodeWithSelection '<b>|hello|<b> <span>world</span>', false, (node) ->
        ed = new Nib.Editor(node: node)
        nodes = ed.getSelectedNodes()

        assert.equal(2, nodes.length)
        assert.equal(node.firstChild.firstChild, nodes[0])
        assert.equal(node.firstChild, nodes[1])

  describe "links", ->
    it "should set href", ->
      testNodeWithSelection '|click here|', true, (node) ->
        ed = new Nib.Editor node: node, plugins:['link']
        ed.activate()
        ed.link.on('http://www.google.com')

        expected = '<a href="http://www.google.com">click here</a>'
        assert.equal(node.innerHTML, expected)

    it "should set http protocol", ->
      testNodeWithSelection '|click here|', true, (node) ->
        ed = new Nib.Editor node: node, plugins:['link']
        ed.activate()
        ed.link.on('www.google.com')

        expected = '<a href="http://www.google.com">click here</a>'
        assert.equal(node.innerHTML, expected)

    it "should not add http to an https protocol", ->
      testNodeWithSelection '|click here|', true, (node) ->
        ed = new Nib.Editor node: node, plugins:['link']
        ed.activate()
        ed.link.on('https://www.google.com')

        expected = '<a href="https://www.google.com">click here</a>'
        assert.equal(node.innerHTML, expected)

    it "should not add http to an ftp protocol", ->
      testNodeWithSelection '|click here|', true, (node) ->
        ed = new Nib.Editor node: node, plugins:['link']
        ed.activate()
        ed.link.on('ftp://www.google.com')

        expected = '<a href="ftp://www.google.com">click here</a>'
        assert.equal(node.innerHTML, expected)

    it "should set http if in middle of url but not the beginning", ->
      testNodeWithSelection '|click here|', true, (node) ->
        ed = new Nib.Editor node: node, plugins:['link']
        ed.activate()
        ed.link.on('www.google-http.com')

        expected = '<a href="http://www.google-http.com">click here</a>'
        assert.equal(node.innerHTML, expected)

    it "should update selected link", ->
      testNodeWithSelection '<a href="http://a">|click here|</a>', true, (node) ->
        ed = new Nib.Editor node: node, plugins:['link']
        ed.activate()
        ed.link.on('b')

        expected = '<a href="http://b">click here</a>'
        assert.equal(node.innerHTML, expected)

  describe "unwrap", ->
    context "for: <b>|hello|</b>", ->
      it "converts to '|hello|'", ->
        testNodeWithSelection "<b>|hello|</b>", false, (node) ->
          ed = new Nib.Editor(node: node)

          ed.unwrap("b")
          assert.equal(node.textContent, "hello")
          markSelection()
          assert.equal(node.innerHTML, "|hello|")

    context "for: |h<b>ell</b>o|", ->
      it "converts to '|hello|'", ->
        testNodeWithSelection "|h<b>ell</b>o|", false, (node) ->
          ed = new Nib.Editor(node: node)

          ed.unwrap("b")
          assert.equal(node.innerHTML, "hello")
          markSelection()
          assert.equal(node.innerHTML, "|hello|")

    context "for: |h<b>el|l</b>o", ->
      it "converts to '|hel|<b>l</b>o'", ->
        testNodeWithSelection "|h<b>el|l</b>o", false, (node) ->
          ed = new Nib.Editor(node: node)

          ed.unwrap("b")
          assert.equal(node.innerHTML, "hel<b>l</b>o")
          markSelection()
          assert.equal(node.innerHTML, "|hel|<b>l</b>o")

    context "for: h<b>|e</b><b>l|</b>lo", ->
      it "converts to 'h|el|lo'", ->
        testNodeWithSelection "h<b>|e</b><b>l|</b>lo", false, (node) ->
          ed = new Nib.Editor(node: node)

          ed.unwrap("b")
          assert.equal(node.innerHTML, "hello")
          markSelection()
          assert.equal(node.innerHTML, "h|el|lo")

    context "for: <b>he|llo|</b>", ->
      it "converts to '<b>he</b>|llo|'", ->
        testNodeWithSelection "<b>he|llo|</b>", false, (node) ->
          ed = new Nib.Editor node: node
          ed.unwrap 'b'
          assert.equal node.innerHTML, "<b>he</b>llo"
          markSelection()
          assert.equal node.innerHTML, "<b>he</b>|llo|"

    context "for: <b>|he|llo</b>", ->
      it "converts to '|he|<b>llo</b>'", ->
        testNodeWithSelection "<b>|he|llo</b>", false, (node) ->
          ed = new Nib.Editor node: node
          ed.unwrap 'b'
          assert.equal node.innerHTML, "he<b>llo</b>"
          markSelection()
          assert.equal node.innerHTML, "|he|<b>llo</b>"

    context "for: <b>h|ell|o</b>", ->
      it "converts to '<b>h</b>ell<b>o</b>'", ->
        testNodeWithSelection "<b>h|ell|o</b>", false, (node) ->
          ed = new Nib.Editor node: node
          ed.unwrap 'b'
          assert.equal node.innerHTML, "<b>h</b>ell<b>o</b>"
          markSelection()
          assert.equal node.innerHTML, "<b>h</b>|ell|<b>o</b>"

    context "for: <b>aa<i>bb|cc|bb</i>aa</b>", ->
      it "converts to <b>aa<i>bb</i></b><i>|cc|</i><b><i>bb</i>aa</b>", ->
        testNodeWithSelection "<b>aa<i>bb|cc|bb</i>aa</b>", false, (node) ->
          ed = new Nib.Editor node: node
          ed.unwrap 'b'
          assert.equal node.innerHTML, "<b>aa<i>bb</i></b><i>cc</i><b><i>bb</i>aa</b>"
          markSelection()
          assert.equal node.innerHTML, "<b>aa<i>bb</i></b><i>|cc|</i><b><i>bb</i>aa</b>"

    context "when text is selected backwards", ->
      context "for: h<b>|e</b><b>l|</b>lo", ->
        it "converts to 'h|el|lo'", ->
          testNodeWithSelection 'h<b>|e</b><b>l|</b>lo', true, (node) ->
            ed = new Nib.Editor(node: node)

            ed.unwrap('b')
            assert.equal(node.innerHTML, 'hello')
            markSelection()
            assert.equal(node.innerHTML, 'h|el|lo')

  describe "events", ->
    it "should pass editor as first parameter to event handlers", ->
      testNode 'p', 'Here is some sample text', (p) ->
        ed = new Nib.Editor node: p
        ed.on 'editor:on', (editor) ->
          assert.equal editor, ed
        ed.activate()

  describe "content introspection", ->
    it "should return the node content", ->
      testNodeWithSelection "Hello |There| World!", false, (node) ->
        ed = new Nib.Editor node: node
        ed.activate()
        assert.equal ed.getContent(),"Hello There World!"

    it "should check if the carat is at the beginning of the node", ->
      testNodeWithSelection "||Hello There World!", false, (node) ->
        ed = new Nib.Editor node: node
        ed.activate()
        assert.equal ed.isCaretAtNodeStart(), true

    it "should check if the carat is at the beginning of the node when nested", ->
      testNodeWithSelection "<b>||Hello There World!</b>", false, (node) ->
        ed = new Nib.Editor node: node
        ed.activate()
        assert.equal ed.isCaretAtNodeStart(), true

    it "should move the carat to the end of the node", ->
      testNodeWithSelection "Hello |There| World!", false, (node) ->
        ed = new Nib.Editor node: node
        ed.activate()
        ed.moveCaretToNodeEnd()
        markSelection()
        assert.equal node.innerHTML, "Hello There World!||"


    describe "with flat content", ->
      it "should get the content before the selection", ->
        testNodeWithSelection "Hello |There| World!", false, (node) ->
          ed = new Nib.Editor node: node
          ed.activate()
          assert.equal ed.contentBeforeSelection(),"Hello "

      it "should get the content in the selection", ->
        testNodeWithSelection "Hello |There| World!", false, (node) ->
          ed = new Nib.Editor node: node
          ed.activate()
          assert.equal ed.contentInSelection(),"There"

      it "should get the content after the selection", ->
        testNodeWithSelection "Hello |There| World!", false, (node) ->
          ed = new Nib.Editor node: node
          ed.activate()
          assert.equal ed.contentAfterSelection()," World!"

    describe "with nested content", ->
      it "should get the content before the selection", ->
        testNodeWithSelection "I am a <i>str|ing</i> with <b>lots</b>| of <b><i>information</i></b>.", false, (node) ->
          ed = new Nib.Editor node: node
          ed.activate()
          assert.equal ed.contentBeforeSelection(),"I am a <i>str</i>"

      it "should get the content in the selection", ->
        testNodeWithSelection "I am a <i>str|ing</i> with <b>lots</b>| of <b><i>information</i></b>.", false, (node) ->
          ed = new Nib.Editor node: node
          ed.activate()
          assert.equal ed.contentInSelection(),"<i>ing</i> with <b>lots</b>"

      it "should get the content after the selection", ->
        testNodeWithSelection "I am a <i>str|ing</i> with <b>lots</b>| of <b><i>information</i></b>.", false, (node) ->
          ed = new Nib.Editor node: node
          ed.activate()
          assert.equal ed.contentAfterSelection()," of <b><i>information</i></b>."

    describe "with deeply nested content", ->
      it "should get the content before the selection", ->
        testNodeWithSelection "<b>Knowl|edge</b> is <b><i>pow|er</i></b>.", false, (node) ->
          ed = new Nib.Editor node: node
          ed.activate()
          assert.equal ed.contentBeforeSelection(),"<b>Knowl</b>"

      it "should get the content in the selection", ->
        testNodeWithSelection "<b>Knowl|edge</b> is <b><i>pow|er</i></b>.", false, (node) ->
          ed = new Nib.Editor node: node
          ed.activate()
          assert.equal ed.contentInSelection(),"<b>edge</b> is <b><i>pow</i></b>"

      it "should get the content after the selection", ->
        testNodeWithSelection "<b>Knowl|edge</b> is <b><i>pow|er</i></b>", false, (node) ->
          ed = new Nib.Editor node: node
          ed.activate()
          assert.equal ed.contentAfterSelection(),"<b><i>er</i></b>"

