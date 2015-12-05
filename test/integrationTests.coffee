{log, p, pjson, json} = require 'lightsaber'
{values} = require 'lodash'
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
  context 'dcos', ->
    context 'dcos#show', ->
      it "shows the user's current project", ->
        dcoId = 'Your Great Project'
        @user = new User(name: userId, current_dco: dcoId, state: 'dcos#show').save()
        dco = new DCO
          name: dcoId
          project_owner: userId
          tasksUrl: 'http://example.com'
        dco.save()
        .then -> dco.createProposal name: 'Do Stuff'
        .then -> dco.createProposal name: 'Be Glorious'
        .then -> App.route message()
        .then (reply)->
          jreply = json reply
          jreply.should.match /See Project Tasks/
          jreply.should.match /example\.com/
          jreply.should.match /Do stuff/i
          jreply.should.match /Be glorious/i
          jreply.should.match /\d: create an award/i

    context 'dcos#index', ->
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

      context 'dcos#create', ->
        beforeEach ->
          nock 'http://example.com'
            .head '/too-large.png'
            .reply 200, '', { 'content-length': App.MAX_SLACK_IMAGE_SIZE + 1, 'content-type': 'image/jpg' }
            .head '/very-small.png'
            .reply 200, '', { 'content-length': App.MAX_SLACK_IMAGE_SIZE - 1, 'content-type': 'image/jpg' }
            .head '/does-not-exist.png'
            .reply 404, ''

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
            json(reply).should.match /Please enter a link to your project tasks./
            @message = message('http://jira.com')
            App.route @message
          .then (reply)=>
            json(reply).should.match /Please enter an image URL/
            @message = message('this is not a valid URL...')
            App.route @message
          .then (reply)=>
            json(reply).should.match /that is not a valid URL.+Please enter an image URL/i
            @message = message('http://example.com/does-not-exist.png')
            App.route @message
          .then (reply)=>
            json(reply).should.match /that address doesn't seem to exist.+Please enter an image URL/
            @message = message('http://example.com/too-large.png')
            App.route @message
          .then (reply)=>
            json(reply).should.match /Sorry, that image is too large.+Please enter an image URL/
            @message = message('http://example.com/very-small.png')
            App.route @message
          .then (reply)=>
            @message.parts[1].should.match /Project created/
          .then => @firebaseServer.getValue()
          .then (db)=>
            db.projects.Supafly.should.deep.eq
              name: 'Supafly'
              project_statement: 'Shaft'
              project_owner: userId
              imageUrl: 'http://example.com/very-small.png'
              tasksUrl: 'http://jira.com'

  context 'proposals', ->
    context 'proposals#create', ->
      it "allows the user to create a award within the current project", ->
        dcoId = 'Your Great Project'
        @user = new User(name: userId, current_dco: dcoId, state: 'dcos#show').save()
        dco = new DCO(name: dcoId)
        dco.save()
        .then -> App.route message()
        .then -> App.route message('4') # create a task
        .then (reply)->
          json(reply).should.match /What is the award name/
          App.route message('Kitais')
        .then (reply)=>
          json(reply).should.match /Enter a suggested amount for this award/
          @message = message('4000')
          App.route @message
        .then (reply)=>
          json(@message.parts).should.match /Award created/
        .then => @firebaseServer.getValue()
        .then (db)=>
          db.projects[dcoId].proposals['Kitais'].should.deep.eq
            name: 'Kitais'
            suggestedAmount: '4000'

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

    context 'proposals#sendReward', ->
      proposalId = 'Be Amazing'
      dcoId = 'my dco'
      user = ->
        new User(name: userId, state: 'proposals#show', stateData: {proposalId: proposalId}, current_dco: dcoId).save()
      dco = ->
        new DCO(name: dcoId, project_owner: userId).save()
      proposal = (dco)->
        dco.createProposal(name: proposalId)

      xit "allows an admin to award coins to a user", ->
        user()
        .then (@user)=> dco()
        .then (@dco)=> proposal(@dco)
        .then (@proposal)=> App.route message('')  # load menu into user
        .then => App.route message('5')

        .then (reply)=> (json reply).should.match /Which slack @user should I send the reward to/i
        .then => App.route message('@duke')

        .then (reply)=> (json reply).should.match /What award type/i
        .then => App.route message('A')

        .then (reply)=> json(reply).should.match /How much do you want to reward @duke for "Be Amazing"/i
        .then => App.route message('4000')

        .then (reply)=> json(reply).should.match /What was the contribution @duke made for the award/i
        .then => App.route message('was awesome')

        .then (reply)=> json(reply).should.match /Initiating transaction.+We will private message both yourself and @duke/
        .then => @firebaseServer.getValue()
        .then (db)=>
          # project -> award -> reward(key: timestamp, issuer, repic, amount, awardType)
          rewards = db.projects[dcoId].proposals[proposalId].rewards
          reward = values(rewards)[0]
          reward.should.deep.eq
            issuer: userId
            recipient: 'slack:dukesID'
            amount: 4000
            awardType: @proposal.key()
          reward.key().should.match /iso.../
