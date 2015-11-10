{log, p, pjson} = require 'lightsaber'
chai = require 'chai'
chai.should()
FirebaseServer = require('firebase-server')
FirebaseModel = require '../../src/models/firebase-model'

MOCK_FIREBASE_ADDRESS = '127.0.1' # strange host name needed by testing framework
process.env.FIREBASE_URL = "ws://#{MOCK_FIREBASE_ADDRESS}:5000"

class SomeModel extends FirebaseModel
  urlRoot: 'fakemodel'

describe 'SomeModel', ->
  before ->
    @firebaseServer = new FirebaseServer 5000, MOCK_FIREBASE_ADDRESS, {}

  # describe '#safeId', ->
  #   it "escapes special characters", ->
  #     SomeModel::key("i am a strange .#$[] id").should.eq 'i-am-a-strange-id'
  #   it "trims dashes from the ends", ->
  #     SomeModel::safeId("...i am a strange .#$[] id --").should.eq 'i-am-a-strange-id'

  describe 'constructor', ->
    it "should have a friendly name and a kebab case ID", ->
      model = new SomeModel name: 'i am a strange .#$[] id'
      model.key().should.eq 'i-am-a-strange-id'
      model.get('name').should.eq 'i am a strange .#$[] id'

    it "should save and be fetchable by name", ->
      model = new SomeModel name: 'A Proper Name', description: 'something'
      model.save()
      .then (model) =>
        # Fetch the model by its name alone
        newModel = new SomeModel name: 'A Proper Name'
        newModel.fetch()
      .then (newModel) =>
        newModel.get('description').should.eq 'something'
