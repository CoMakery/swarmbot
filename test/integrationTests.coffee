{log, p, pjson, json} = require 'lightsaber'
Promise = require 'bluebird'
require './testHelper'
global.App = require '../src/app'
DCO = require '../src/models/dco'
User = require '../src/models/user'
nock = require 'nock'

userId = "slack:1234"

nock('http://example.com')
  .head '/too-large.png'
  .reply 200, '', { 'content-length': (Math.pow 2, 17) }
  .head '/very-small.png'
  .reply 200, '', { 'content-length': (Math.pow 2, 15) }

message = (input) ->
  @parts = []
  {
    parts: @parts
    match: [null, input]
    send: (reply) => throw new Error "deprecated, use pmReply"
    robot:
      whose: (msg) -> userId
      messageRoom: ->
      pmReply: (msg, attachment) =>
        reply = attachment.text or attachment
        @parts.push reply
  }

describe 'swarmbot', ->
  context 'general#home', ->
    context 'with no proposals', ->
      it "shows the default community", ->
        App.route message('')
        .then (reply) ->
          jreply = json reply
          jreply.should.match /no proposals/
          jreply.should.match /\d: cap table/
          jreply.should.match /\d: advanced commands/

      it "allows the user to create a proposal within the current community", ->
        dcoId = 'Your Great Community'
        @user = new User(name: userId, current_dco: dcoId).save()
        dco = new DCO(name: dcoId)
        dco.save()
        .then -> App.route message()
        .then -> App.route message('1')
        .then (reply) ->
          json(reply).should.match /What is the name of your proposal/
          App.route message('A Proposal.')
        .then (reply) =>
          json(reply).should.match /Please enter a brief description of your proposal/
          @message = message('A description')
          App.route @message
        .then (reply) =>
          json(reply).should.match /Please enter an image URL for your proposal/
          @message = message('http://example.com/too-large.png')
          App.route @message
        .then (reply) =>
          json(reply).should.match /Sorry, that image is too large.+Please enter an image URL for your proposal/
          @message = message('http://example.com/very-small.png')
          App.route @message
        .then (reply) =>
          @message.parts.length.should.eq 1
          @message.parts[0].should.match /Proposal created/
          (json reply).should.match /View Current Proposals/
        # TODO check that proposal exists with those attributes

    it "shows the user's current community, with proposals", ->
      dcoId = 'Your Great Community'
      @user = new User(name: userId, current_dco: dcoId).save()
      dco = new DCO(name: dcoId)
      dco.save()
      .then -> dco.createProposal name: 'Do Stuff'
      .then -> dco.createProposal name: 'Be Glorious'
      .then -> App.route message('1')
      .then (reply) ->
        jreply = json reply
        jreply.should.match /View Current Proposals/
        jreply.should.match /[A-B]: do stuff/i
        jreply.should.match /[A-B]: be glorious/i
        jreply.should.match /\d: create a proposal/i

  context 'users#setDco', ->
    it "shows the list of name: and sets current dco", ->
      i = 1
      Promise.all [
        new DCO(name: "Community #{i++}").save()
        new DCO(name: "Community #{i++}").save()
        new DCO(name: "Community #{i++}").save()
      ]
      .then (@dcos) => new User(name: userId, state: 'users#setDco').save()
      .then (@user) => App.route message()
      .then (reply) =>
        jreply = json(reply)
        jreply.should.match /Set Current Project/
        jreply.should.match /[1-3]: Community [1-3]/
        @message = message('1')
        App.route @message
      .then (reply) =>
        @message.parts[0].should.match /Project set to Community \d/

  context 'general#home', ->
    userId = 'Me'
    dcoId = 'First Distributed Federation'
    user = ->
      new User(name: userId, state: 'general#home', current_dco: dcoId).save()
    dco = ->
      new DCO(name: dcoId, project_owner: userId).save()
    it "shows the list of proposals in order of votes", ->
      user()
      .then (@user) => dco()
      .then (@dco) => @dco.createProposal(name: 'A1')
      .then (@proposalA) => @dco.createProposal(name: 'B2')
      .then (@proposalB) => App.route message()
      .then (reply) =>
        (json reply).should.match /.: a1\\n.: b2/i
        @proposalB.upvote(@user)
      .then => @proposalB.fetch()
      .then (@proposalB) =>
        App.route message('h')
      .then (reply) =>
        (json reply).should.match /.: b2\\n.: a1/i

  context 'proposals#show', ->
    context 'setBounty', ->
      proposalId = 'Be Amazing'
      dcoId = 'my dco'
      user = ->
        new User(name: userId, state: 'proposals#show', stateData: {proposalId: proposalId}, current_dco: dcoId).save()
      dco = ->
        new DCO(name: dcoId, project_owner: userId).save()
      proposal = (dco) ->
        dco.createProposal(name: proposalId)

      it "shows setBounty item only for progenitors", ->
        user()
        .then (@user) => dco()
        .then (@dco) => proposal(@dco)
        .then (@proposal) => App.route message()
        .then (reply) =>
          (json reply).should.match /\d: set reward/i
          @dco.set 'project_owner', 'someoneElse'
        .then (@dco) => App.route message()
        .then (reply) =>
          (json reply).should.not.match /\d: set reward/i

      it "sets the bounty", ->
        user()
        .then (@user) => dco()
        .then (@dco) => proposal(@dco)
        .then (@proposal) => App.route message()
        .then (reply) => App.route message('4') # Set Bounty
        .then (reply) =>
          json(reply).should.match /Enter the bounty amount/
          @message = message '1000'
          App.route @message
        .then (reply) =>
          @message.parts[0].should.match /Bounty amount set to 1000/
          (json reply).should.match /proposal: be amazing/i
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
          json(reply).should.match /Enter the bounty amount/

  context 'solutions#sendReward', ->
    proposalId = 'Be Amazing'
    solutionId = 'Self Love'
    solutionCreatorId = "slack:4388"
    dcoId = 'my dco'
    admin = ->
      new User
        name: userId
        state: 'solutions#show'
        stateData: {solutionId, proposalId}
        current_dco: dcoId
      .save()
    solutionCreator = ->
      new User
        name: solutionCreatorId
        slack_username: 'noah'
        btc_address: 'abc123'
      .save()
    dco = -> new DCO(name: dcoId, project_owner: userId).save()
    proposal = (dco) -> dco.createProposal(name: proposalId)
    solution = (proposal) -> proposal.createSolution name: solutionId, userId: solutionCreatorId

    it "allows the progenitor to send a reward for a solution", ->
      admin()
      .then => solutionCreator()
      .then (@solutionCreator) => dco()
      .then (@dco) => proposal @dco
      .then (@proposal) => solution @proposal
      .then (@solution) => App.route message ''
      .then (reply) => App.route message('2') # Send Reward
      .then (reply) =>
        json(reply).should.match /Enter reward amount to send to noah for the solution 'Self Love'/
      .then =>
        @message = message('1000') # Reward amount
        App.route @message
      .then (reply) =>
        @message.parts[0].should.match /Initiating transaction/

  context 'solutions#index', ->
    userId = 'Me'
    dcoId = 'First Distributed Federation'
    user = ->
      new User
        name: userId
        state: 'solutions#index'
        current_dco: dcoId
        stateData: {proposalId: 'proposal' }
      .save()
    dco = ->
      new DCO(name: dcoId, project_owner: userId).save()
    it "shows the list of proposals in order of votes", ->
      user()
      .then (@user) => dco()
      .then (@dco) => @dco.createProposal(name: 'proposal')
      .then (@proposal) => @proposal.createSolution(name: 'solution A')
      .then (@solutionA) => @proposal.createSolution(name: 'solution B')
      .then (@solutionB) => App.route message()
      .then (reply) =>
        (json reply).should.match /.: solution a\\n.: solution b/i
        @solutionB.upvote(@user)
      .then => @solutionB.fetch()
      .then (@solutionB) =>
        App.route message('')
      .then (reply) =>
        (json reply).should.match /.: solution b\\n.: solution a/i
