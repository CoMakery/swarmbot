{log, p, pjson} = require 'lightsaber'
FirebaseModel = require '../../src/models/firebase-model'
require '../testHelper'

class SomeModel extends FirebaseModel
  urlRoot: 'fakemodel'

describe 'SomeModel', ->

  describe 'constructor', ->
    it "should have a friendly name and a kebab case ID", ->
      model = new SomeModel name: 'i am a strange - .#$[] - name'
      model.key().should.eq 'i am a strange - ----- - name'
      model.get('name').should.eq 'i am a strange - .#$[] - name'

    it "should save and be fetchable by name", ->
      model = new SomeModel name: 'A Proper Name', description: 'something'
      model.save()
      .then (model)=>
        # Fetch the model by its name alone
        newModel = new SomeModel name: 'A Proper Name'
        newModel.fetch()
      .then (newModel)=>
        newModel.get('description').should.eq 'something'
