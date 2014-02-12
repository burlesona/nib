assert = chai.assert

describe 'Nib.Events', ->
  describe 'constructor', ->
    it 'should init with this.handlers', ->
      obj = new Nib.Events
      assert.ok obj.handlers

  describe 'on', ->
    it 'should attach a function that fires on trigger', (done) ->
      obj = new Nib.Events
      obj.on 'test', ->
        assert true
        done()
      obj.trigger 'test'

  describe 'off', ->
    it 'should remove a function and not fire it', (done) ->
      pass = true
      obj = new Nib.Events
      removeFn = ->
        pass = false
      obj.on 'test', removeFn
      obj.off 'test', removeFn
      obj.on 'test', ->
        assert pass, 'function was not removed'
        done()
      obj.trigger 'test'

  describe 'trigger', ->
    it 'should call a handler function', (done) ->
      obj = new Nib.Events
      obj.on 'test', ->
        assert true
        done()
      obj.trigger 'test'

    it 'should not call handlers for a different event', (done) ->
      obj = new Nib.Events
      pass = true
      failFn = ->
        pass = false
      obj.on 'other', failFn
      obj.on 'test', ->
        assert pass, 'other function was called'
        done()
      obj.trigger 'test'

  describe 'clear', ->
    it 'should clear all bound functions', ->
      pass = true
      obj = new Nib.Events
      failFn = ->
        pass = false
      obj.on 'test', failFn
      obj.clear()
      obj.trigger 'test'
      assert pass, 'fail function was called'

