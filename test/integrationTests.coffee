{log, p, pjson} = require 'lightsaber'
chai = require 'chai'
chaiAsPromised = require("chai-as-promised")
chai.should()
chai.use(chaiAsPromised);
debug = require('debug')('test')
FirebaseServer = require('firebase-server')
App = require '../src/app'
DCO = require '../src/models/dco'
User = require '../src/models/user'

process.env.FIREBASE_URL = 'ws://127.0.1:5000'

describe 'swarmbot', ->
  before ->
    @firebaseServer = new FirebaseServer 5000, '127.0.1', {}

  afterEach ->
    debug 'FB data:'
    debug pjson @firebaseServer.getData()

  after ->
    @firebaseServer.close()

  context 'home', ->
    it "shows the default community, with no proposals", ->
      userId = "slack:1234"
      msg =
        match: [null, "help"]
        robot:
          whose: (msg) -> userId

      App.route(msg)
      .then (reply) ->
        reply.should.match /\*No proposals in swarmbot-lovers\*/
        reply.should.match /1: Create a proposal/
        reply.should.match /2: More commands/

    it "shows the user's current community, with proposals", ->
      dcoId = 'Your Great Community'
      userId = "slack:1234"
      @user = new User(id: userId, current_dco: dcoId).save()
      msg =
        match: [null, "help"]
        robot:
          whose: (msg) -> userId
      dco = new DCO(id: dcoId)
      dco.save()
      .then -> dco.createProposal id: 'Do Stuff'
      .then -> dco.createProposal id: 'Be Glorious'
      .then -> App.route(msg)
      .then (reply) ->
        reply.should.match /\*Proposals in Your Great Community\*/
        reply.should.match /[1-2]: Do Stuff/
        reply.should.match /[1-2]: Be Glorious/
        reply.should.match /3: Create a proposal/
