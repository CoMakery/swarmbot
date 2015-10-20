{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
chai = require 'chai'
chaiAsPromised = require("chai-as-promised")
chai.should()
chai.use(chaiAsPromised);
debug = require('debug')('test')
FirebaseServer = require('firebase-server')
global.App = require '../src/app'
swarmbot = require '../src/models/swarmbot'
DCO = require '../src/models/dco'
User = require '../src/models/user'

process.env.FIREBASE_URL = 'ws://127.0.1:5000'

userId = "slack:1234"
message = (input) ->
  match: [null, input]
  robot:
    whose: (msg) -> userId
  send: (reply) ->
    @parts ?= []
    @parts.push reply

describe 'swarmbot', ->
  before ->
    @firebaseServer = new FirebaseServer 5000, '127.0.1', {}

  beforeEach (done) ->
    swarmbot.firebase().remove done

  afterEach ->
    debug 'FB data:'
    debug pjson @firebaseServer.getData()

  after ->
    @firebaseServer.close()

  context 'general#home', ->
    context 'with no proposals', ->
      it "shows the default community", ->
        App.route message('help')
        .then (reply) ->
          reply.should.match /\*No proposals in swarmbot-lovers\*/
          reply.should.match /1: Create a proposal/
          reply.should.match /2: More commands/

      it "allows the user to create a proposal within the current community", ->
        dcoId = 'Your Great Community'
        @user = new User(id: userId, current_dco: dcoId).save()
        dco = new DCO(id: dcoId)
        dco.save()
        .then -> App.route message()
        .then -> App.route message('1')
        .then (reply) ->
          reply.should.match /What is the name of your proposal/
          App.route message('A Proposal')
        .then (reply) =>
          reply.should.match /Please enter a brief description of your proposal/
          @message = message('A description')
          App.route @message
        .then (reply) =>
          @message.parts.length.should.eq 1
          @message.parts[0].should.match /Proposal created/
          reply.should.match /\*Proposals in Your Great Community\*/

    it "shows the user's current community, with proposals", ->
      dcoId = 'Your Great Community'
      @user = new User(id: userId, current_dco: dcoId).save()
      dco = new DCO(id: dcoId)
      dco.save()
      .then -> dco.createProposal id: 'Do Stuff'
      .then -> dco.createProposal id: 'Be Glorious'
      .then -> App.route message('1')
      .then (reply) ->
        reply.should.match /\*Proposals in Your Great Community\*/
        reply.should.match /[1-2]: Do Stuff/
        reply.should.match /[1-2]: Be Glorious/
        reply.should.match /3: Create a proposal/

  context 'users#setDco', ->
    xit "shows the list of dcos", ->
      i = 1
      dcosPromise = Promise.all [
        new DCO(id: "Community #{i++}").save()
        new DCO(id: "Community #{i++}").save()
        new DCO(id: "Community #{i++}").save()
      ]

      dcosPromise
      .then (@dcos) => new User(id: userId, state: 'general#more').save()
      .then (@user) => App.route message()
      .then (reply) => App.route message('1')
      .then (reply) =>
        reply.should.match /\*Set Current Community\*/
        reply.should.match /[1-3]: Community [1-3]/

# TODO:
# test if current dco does not exist, should default
