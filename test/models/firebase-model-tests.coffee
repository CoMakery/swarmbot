require '../helpers/test-helper'
{log, p, pjson} = require 'lightsaber'
FirebaseModel = require '../../src/models/firebase-model'

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

  describe 'camel case keys', ->
    it "should allow camel case keys", ->
      model = new SomeModel name: 'foo', camelKey: 'Yup'
      model.save()
      model.get('camelKey').should.eq 'Yup'

    it "should allow date-like keys", ->
      model = new SomeModel name: 'foo', '2015-12-19T01:17:12': 'Yup'
      model.save()
      model.get('2015-12-19T01:17:12').should.eq 'Yup'

    it "should disallow top level keys which are not either camel case or dates", ->
      ( -> new SomeModel "friendly key": 'Nope' ).should.throw /Expected all DB keys to be camel case or dates/
      ( -> new SomeModel "kebab-key":    'Nope' ).should.throw /Expected all DB keys to be camel case or dates/
      ( -> new SomeModel "TitleKey":     'Nope' ).should.throw /Expected all DB keys to be camel case or dates/
      ( -> new SomeModel "snake_key":    'Nope' ).should.throw /Expected all DB keys to be camel case or dates/

    it "should allow lower level keys which are not camel case or dates", ->
      model = new SomeModel name: 'foo', topLevelKey: {"second level key": 'Fine'}
      model.save()
      model.get('topLevelKey').should.deep.eq {"second level key": 'Fine'}
