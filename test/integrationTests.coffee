{log, p, pjson} = require 'lightsaber'
chai = require 'chai'
chaiAsPromised = require("chai-as-promised")
chai.should()
chai.use(chaiAsPromised);
FirebaseServer = require('firebase-server')
App = require '../src/app'
DCO = require '../src/models/dco'

process.env.FIREBASE_URL = 'ws://127.0.1:5000'

describe 'swarmbot', ->
  before ->
    @firebaseServer = new FirebaseServer 5000, '127.0.1'

  after ->
    p @firebaseServer.getData()
    @firebaseServer.close()

  context 'home', ->

    it "shows no proposals for the default dco", ->
      userId = "slack:1234"
      # @user = new User(id: userId).save()
      # @dco = new DCO(id: "Test DCO").save()
      msg =
        match: [null, "help"]
        robot:
          whose: (msg) -> userId

      reply = App.route(msg)
      reply.should.eventually.match /\*No proposals in swarmbot-lovers\*/
      reply.should.eventually.match /1: Create a proposal/
      reply.should.eventually.match /2: More commands/
