assert = chai.assert

describe 'Nib Plugins', ->
  describe 'registry', ->
    it 'should store plugins at Nib.Plugins', ->
      assert.ok Nib.Plugins
      assert.ok Nib.Plugins.Base
      assert.ok Nib.Plugins.Bold

  describe 'extension', ->
    testNode = document.createElement('p')
    it 'should add methods to editor when listed', ->
      editor = new Nib.Editor node: testNode, plugins: ['bold']
      editor.activate()
      assert.ok editor.bold

    it 'should not add methods that have not been listed', ->
      editor = new Nib.Editor node: testNode, plugins: ['bold']
      editor.activate()
      assert.notOk editor.italic

    it 'should list active plugins', ->
      editor = new Nib.Editor node: testNode, plugins: ['bold']
      assert.deepEqual editor.plugins, ['bold']
