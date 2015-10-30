{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
chai = require 'chai'
chaiAsPromised = require("chai-as-promised")
chai.should()
chai.use(chaiAsPromised)
debug = require('debug')('test')
FirebaseServer = require('firebase-server')
sinon = require 'sinon'
# require('sinon-as-promised')(Promise)
# require 'sinon-chai'

global.App = require '../src/app'
swarmbot = require '../src/models/swarmbot'
DCO = require '../src/models/dco'
User = require '../src/models/user'

MOCK_FIREBASE_ADDRESS = '127.0.1' # strange host name needed by testing framework
process.env.FIREBASE_URL = "ws://#{MOCK_FIREBASE_ADDRESS}:5000"


sinon.stub(swarmbot, 'colu').returns Promise.resolve
  on: ->
  init: ->
  sendAsset: (x, cb)-> cb(null, {txid: 1234})
  issueAsset: ->


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
    @firebaseServer = new FirebaseServer 5000, MOCK_FIREBASE_ADDRESS, {}

  beforeEach (done) ->
    swarmbot.firebase().remove done

  afterEach ->
    debug 'FB data:'
    debug pjson @firebaseServer.getValue()

  after ->
    @firebaseServer.close()

  context 'general#home', ->
    context 'with no proposals', ->
      it "shows the default community", ->
        App.route message('')
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
    it "shows the list of dcos and sets current dco", ->
      i = 1
      Promise.all [
        new DCO(id: "Community #{i++}").save()
        new DCO(id: "Community #{i++}").save()
        new DCO(id: "Community #{i++}").save()
      ]
      .then (@dcos) => new User(id: userId, state: 'general#more').save()
      .then (@user) => App.route message()
      .then (reply) => App.route message('1')
      .then (reply) =>
        reply.should.match /\*Set Current Community\*/
        reply.should.match /[1-3]: Community [1-3]/
        @message = message('1')
        App.route @message
      .then (reply) =>
        @message.parts[0].should.match /Community set to Community \d/

  context 'proposals#show', ->
    context 'setBounty', ->
      proposalId = 'Be Amazing'
      dcoId = 'my dco'
      user = ->
        new User(id: userId, state: 'proposals#show', stateData: {id: proposalId}, current_dco: dcoId).save()
      dco = ->
        new DCO(id: dcoId, project_owner: userId).save()
      proposal = (dco) ->
        dco.createProposal(id: proposalId)

      it "shows setBounty item only for progenitors", ->
        user()
        .then (@user) => dco()
        .then (@dco) => proposal(@dco)
        .then (@proposal) => App.route message()
        .then (reply) =>
          reply.should.match /\d: Set Bounty/
          @dco.set 'project_owner', 'someoneElse'
        .then (@dco) => App.route message()
        .then (reply) =>
          reply.should.not.match /\d: Set Bounty/

      it "sets the bounty", ->
        user()
        .then (@user) => dco()
        .then (@dco) => proposal(@dco)
        .then (@proposal) => App.route message()
        .then (reply) => App.route message('4') # Set Bounty
        .then (reply) =>
          reply.should.match /Enter the bounty amount/
          @message = message '1000'
          App.route @message
        .then (reply) =>
          @message.parts[0].should.match /Bounty amount set to 1000/
          reply.should.match /Proposal: Be Amazing/
          @proposal.fetch()
        .then (proposal) => proposal.get('amount').should.eq '1000'

      it "doesn't set the bounty if you enter non-numbers", ->
        user()
        .then (@user) => dco()
        .then (@dco) => proposal(@dco)
        .then (@proposal) => App.route message()
        .then (reply) => App.route message('4') # Set Bounty
        .then (reply) =>
          @message = message '1000x'
          App.route @message
        .then (reply) =>
          @message.parts[0].should.match /please enter only numbers/i
          reply.should.match /Enter the bounty amount/

  context 'solutions#sendReward', ->
    proposalId = 'Be Amazing'
    solutionId = 'Self Love'
    solutionCreatorId = "slack:4388"
    dcoId = 'my dco'
    admin = ->
      new User
        id: userId
        state: 'solutions#show'
        stateData: {solutionId, proposalId}
        current_dco: dcoId
      .save()
    solutionCreator = ->
      new User
        id: solutionCreatorId
        slack_username: 'noah'
        btc_address: 'abc123'
      .save()
    dco = -> new DCO(id: dcoId, project_owner: userId).save()
    proposal = (dco) -> dco.createProposal(id: proposalId)
    solution = (proposal) -> proposal.createSolution id: solutionId, userId: solutionCreatorId

    it "allows the progenitor to send a reward for a solution", ->
      admin()
      .then => solutionCreator()
      .then (@solutionCreator) => dco()
      .then (@dco) => proposal @dco
      .then (@proposal) => solution @proposal
      .then (@solution) => App.route message ''
      .then (reply) => App.route message('2') # Send Reward
      .then (reply) =>
        reply.should.match /Enter reward amount to send to noah for the solution 'Self Love'/
      .then =>
        @message = message('1000') # Reward amount
        App.route @message
      .then (reply) =>
        @message.parts[0].should.match /Initiating transaction/
