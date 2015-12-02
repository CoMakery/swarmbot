{log, p, pjson, json} = require 'lightsaber'
Promise = require 'bluebird'
require './testHelper'
global.App = require '../src/app'
DCO = require '../src/models/dco'
User = require '../src/models/user'
nock = require 'nock'
sinon = require 'sinon'

userId = "slack:1234"

message = (input)->
  @parts = []
  {
    parts: @parts
    match: [null, input]
    send: (reply)=> throw new Error "deprecated, use pmReply"
    robot:
      whose: (msg)-> userId
      messageRoom: ->
      pmReply: (msg, attachment)=>
        reply = attachment.text or attachment
        @parts.push reply
  }

describe 'swarmbot', ->
  context 'dcos#show', ->
    beforeEach ->
      nock 'http://example.com'
        .head '/too-large.png'
        .reply 200, '', { 'content-length': App.MAX_SLACK_IMAGE_SIZE + 1, 'content-type': 'image/jpg' }
        .head '/very-small.png'
        .reply 200, '', { 'content-length': App.MAX_SLACK_IMAGE_SIZE - 1, 'content-type': 'image/jpg' }
        .head '/does-not-exist.png'
        .reply 404, ''

    context 'with no proposals', ->
      it "allows the user to create a task within the current project", ->
        dcoId = 'Your Great Project'
        @user = new User(name: userId, current_dco: dcoId, state: 'dcos#show').save()
        dco = new DCO(name: dcoId)
        dco.save()
        .then -> App.route message()
        .then -> App.route message('4') # create a task
        .then (reply)->
          json(reply).should.match /What is the name of your task/
          App.route message('A Task')
        .then (reply)=>
          json(reply).should.match /Please enter a brief description of your task/
          @message = message('A description')
          App.route @message
        .then (reply)=>
          json(reply).should.match /Please enter an image URL for your task/
          @message = message('this is not a valid URL...')
          App.route @message
        .then (reply)=>
          json(reply).should.match /that is not a valid URL.+Please enter an image URL for your task/i
          @message = message('http://example.com/does-not-exist.png')
          App.route @message
        .then (reply)=>
          json(reply).should.match /that address doesn't seem to exist.+Please enter an image URL for your task/
          @message = message('http://example.com/too-large.png')
          App.route @message
        .then (reply)=>
          json(reply).should.match /Sorry, that image is too large.+Please enter an image URL for your task/
          @message = message('http://example.com/very-small.png')
          App.route @message
        .then (reply)=>
          @message.parts.length.should.eq 2
          @message.parts[1].should.match /Task created/
          (json reply).should.match /View Current Proposals/
        .then => @firebaseServer.getValue()
        .then (db)=>
          db.projects[dcoId].proposals['A Task'].should.deep.eq
            name: 'A Task'
            description: "A description"
            imageUrl: "http://example.com/very-small.png"

    it "shows the user's current community, with proposals", ->
      dcoId = 'Your Great Project'
      @user = new User(name: userId, current_dco: dcoId, state: 'dcos#show').save()
      dco = new DCO(name: dcoId)
      dco.save()
      .then -> dco.createProposal name: 'Do Stuff'
      .then -> dco.createProposal name: 'Be Glorious'
      .then -> App.route message('1')
      .then (reply)->
        jreply = json reply
        jreply.should.match /View Current Proposals/
        jreply.should.match /[A-B]: do stuff/i
        jreply.should.match /[A-B]: be glorious/i
        jreply.should.match /\d: create a task/i

  context 'dcos controller', ->
    context 'index', ->
      beforeEach ->
        @user = new User(name: userId, state: 'dcos#index')
        sinon.stub(@user, 'balances').onCall(1).returns Promise.resolve [
          {
            name: 'FinTechHacks'
            assetId: 'xyz123'
            balance: 456
          }
        ]

      it "shows a welcome screen if there are no projects", ->
        @user.save()
        .then (@user)=> App.route message()
        .then (reply)=>
          jreply = json(reply)
          jreply.should.match /Welcome friend!/
          jreply.should.match /Let's get started.*Type 1/
          App.route message('1')
        .then (reply)=>
          json(reply).should.match /What is the name of this project/

      it "shows the list of names and sets current dco", ->
        Promise.all [
          new DCO(name: "Community A").save()
          new DCO(name: "Community B").save()
          new DCO(name: "Community C").save()
        ]
        .then (@dcos)=> @user.save()
        .then (@user)=> App.route message()
        .then (reply)=>
          jreply = json(reply)
          # jreply.should.match /Contribute to projects and get rewarded with project coins/
          jreply.should.match /Set Current Project/
          jreply.should.match /A: Community A/
          jreply.should.match /B: Community B/
          jreply.should.match /C: Community C/
          @message = message('A')
          App.route @message
        .then (reply)=>
          json(reply).should.match /Community A/i

      context 'create', ->
        it "asks questions and creates a project", ->
          @user.save()
          .then (@user)=> App.route message()
          .then (reply)=> App.route message('1')
          .then (reply)=>
            json(reply).should.match /What is the name of this project/
            App.route message('Supafly')
          .then (reply)=>
            json(reply).should.match /Please enter a short description/
            @message = message('Shaft')
            App.route @message
          .then (reply)=>
            @message.parts[0].should.match /Project created/
          .then => @firebaseServer.getValue()
          .then (db)=>
            db.projects.Supafly.should.deep.eq
              name: 'Supafly'
              project_statement: 'Shaft'
              project_owner: userId

  context 'dcos#show', ->
    userId = 'Me'
    dcoId = 'First Distributed Federation'
    user = ->
      new User(name: userId, state: 'dcos#show', current_dco: dcoId).save()
    dco = ->
      new DCO(name: dcoId, project_owner: userId).save()
    it "shows the list of proposals in order of votes", ->
      user()
      .then (@user)=> dco()
      .then (@dco)=> @dco.createProposal(name: 'A1')
      .then (@proposalA)=> @dco.createProposal(name: 'B2')
      .then (@proposalB)=> App.route message()
      .then (reply)=>
        (json reply).should.match /.: a1\\n.: b2/i
        @proposalB.upvote(@user)
      .then => @proposalB.fetch()
      .then (@proposalB)=>
        App.route message('h')
      .then (reply)=>
        (json reply).should.match /.: b2\\n.: a1/i

  context 'proposals#show', ->
    context 'setBounty', ->
      proposalId = 'Be Amazing'
      dcoId = 'my dco'
      user = ->
        new User(name: userId, state: 'proposals#show', stateData: {proposalId: proposalId}, current_dco: dcoId).save()
      dco = ->
        new DCO(name: dcoId, project_owner: userId).save()
      proposal = (dco)->
        dco.createProposal(name: proposalId)

      it "shows setBounty item only for progenitors", ->
        user()
        .then (@user)=> dco()
        .then (@dco)=> proposal(@dco)
        .then (@proposal)=> App.route message()
        .then (reply)=>
          (json reply).should.match /\d: set reward/i
          @dco.set 'project_owner', 'someoneElse'
        .then (@dco)=> App.route message()
        .then (reply)=>
          (json reply).should.not.match /\d: set reward/i

      it "sets the bounty", ->
        user()
        .then (@user)=> dco()
        .then (@dco)=> proposal(@dco)
        .then (@proposal)=> App.route message()
        .then (reply)=> App.route message('4') # Set Bounty
        .then (reply)=>
          json(reply).should.match /Enter the bounty amount/
          @message = message '1000'
          App.route @message
        .then (reply)=>
          @message.parts[0].should.match /Bounty amount set to 1000/
          (json reply).should.match /task: be amazing/i
          @proposal.fetch()
        .then (proposal)=> proposal.get('amount').should.eq '1000'

      it "doesn't set the bounty if you enter non-numbers", ->
        user()
        .then (@user)=> dco()
        .then (@dco)=> proposal(@dco)
        .then (@proposal)=> App.route message()
        .then (reply)=> App.route message('4') # Set Bounty
        .then (reply)=>
          @message = message '1000x'
          App.route @message
        .then (reply)=>
          @message.parts[0].should.match /please enter only numbers/i
          json(reply).should.match /Enter the bounty amount/

  context 'solutions#sendReward', ->
    proposalId = 'Be Amazing'
    solutionId = 'Self Love'
    solutionCreatorId = "slack:4388"
    dcoId = 'my dco'
    user = ->
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
    dco = (ownerId)-> new DCO(name: dcoId, project_owner: ownerId).save()
    proposal = (dco)-> dco.createProposal(name: proposalId)
    solution = (proposal)-> proposal.createSolution name: solutionId, userId: solutionCreatorId

    it "allows the progenitor to send a reward for a solution", ->
      user()
      .then (@user)=> solutionCreator()
      .then (@solutionCreator)=> dco(userId)
      .then (@dco)=> proposal @dco
      .then (@proposal)=> solution @proposal
      .then (@solution)=> App.route message ''
      .then (reply)=> App.route message('2') # Send Reward
      .then (reply)=>
        json(reply).should.match /Enter reward amount to send to noah for the solution 'Self Love'/
        @message = message('1000') # Reward amount
        App.route @message
      .then (reply)=>
        @message.parts[0].should.match /Initiating transaction/

    it "disallows anyone else from sending a reward for a solution", ->
      user()
      .then (@user)=> solutionCreator()
      .then (@solutionCreator)=> dco(solutionCreatorId)
      .then (@dco)=> proposal @dco
      .then (@proposal)=> solution @proposal
      .then (@solution)=> App.route message ''
      .then (reply)=>
        json(reply).should.not.match /send reward/


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
      .then (@user)=> dco()
      .then (@dco)=> @dco.createProposal(name: 'proposal')
      .then (@proposal)=> @proposal.createSolution(name: 'solution A')
      .then (@solutionA)=> @proposal.createSolution(name: 'solution B')
      .then (@solutionB)=> App.route message()
      .then (reply)=>
        (json reply).should.match /.: solution a\\n.: solution b/i
        @solutionB.upvote(@user)
      .then => @solutionB.fetch()
      .then (@solutionB)=>
        App.route message('')
      .then (reply)=>
        (json reply).should.match /.: solution b\\n.: solution a/i
