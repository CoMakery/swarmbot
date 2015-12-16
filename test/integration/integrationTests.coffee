{json, log, p, pjson, type} = require 'lightsaber'
{size, values} = require 'lodash'
Promise = require 'bluebird'
nock = require 'nock'
sinon = require 'sinon'

{ createUser, createProject } = require '../helpers/testHelper'
global.App = require '../../src/app'
Project = require '../../src/models/project'
User = require '../../src/models/user'
RewardType = require '../../src/models/reward-type'
InitBot = require '../../src/bots/!init'

USER_ID = "slack:1234"
PROJECT_ID = 'Your Great Project'

App.robot =
  whose: (msg)-> USER_ID
  messageRoom: ->
  adapter:
    customMessage: ->

App.pmReply = (msg, textOrAttachments)=>
  reply = textOrAttachments.text or textOrAttachments
  msg.parts.push reply

message = (input, user)->
  @parts = []
  {
    parts: @parts
    match: [null, input]
    send: (reply)=> throw new Error "deprecated, use pmReply"
    message:
      user:
        name: 'frank'
        id: USER_ID
        real_name: 'Frank Herbert'
        email_address: 'frank@herbert.com'
    robot: App.robot
  }

App.sendMessage = (channel, textOrAttachments)=>
  msg = textOrAttachments.text or textOrAttachments
  App.sendMessage.deliveries[channel] ?= []
  App.sendMessage.deliveries[channel].push msg

describe 'swarmbot', ->
  beforeEach ->
    App.sendMessage.deliveries = {}

  context 'projects', ->
    context 'projects#show', ->
      it "shows the user's current project", ->
        createUser
          name: USER_ID
          state: 'projects#show'
        .then (@user)=>
          createProject()
        .then (@project)=> @project.createRewardType name: 'Do Stuff'
        .then => @project.createRewardType name: 'Be Glorious'
        .then => App.route message()
        .then (reply)=>
          jreply = json reply
          jreply.should.match /See Project Tasks/
          jreply.should.match /example\.com/
          jreply.should.match /Do stuff/i
          jreply.should.match /Be glorious/i
          jreply.should.match /\d: create an award/i
          jreply.should.match /bitcoin address: 3HNSiAq7wFDaPsYDcUxNSRMD78qVcYKicw/i

    context 'projects#index', ->
      beforeEach ->
        createUser
          name: USER_ID
          state: 'projects#index'
          has_interacted: true
        .then (@user)=>

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

      it "shows a welcome screen if the user has never made contact", ->
        @user.set 'has_interacted', false
        .then (@user)=> createProject(name: "Community A")
        .then (@project)=> App.route message()
        .then (reply)=>
          jreply = json(reply)
          jreply.should.match /Welcome friend!/
          jreply.should.match /Let's get started.*Type 1/
          App.route message('xyz')
        .then (reply)=>
          jreply = json(reply)
          jreply.should.match /Contribute to projects/
          jreply.should.not.match /Welcome friend!/

      it "shows the list of names and sets current project", ->
        Promise.all [
          createProject(name: "Community A")
          createProject(name: "Community B")
          createProject(name: "Community C")
        ]
        .then =>
          App.route message()
        .then (reply)=>
          jreply = json(reply)
          jreply.should.match /Choose a Project/
          jreply.should.match /A: Community A/
          jreply.should.match /B: Community B/
          jreply.should.match /C: Community C/
          App.route message('A')
        .then (reply)=>
          json(reply).should.match /Community A/i

      it "shows the list of rewards", ->
        createUser
          name: USER_ID
          slack_username: "joe"
          real_name: 'Joe User'
          state: 'projects#show'
          current_project: "Community A"
          has_interacted: true
        .then (@user)=>
          createProject(name: "Community A")
        .then (@project)=>
          @project.createRewardType(name: "Super sweet award", suggestedAmount: 100)
        .then (@rewardType)=>
          @project.createReward
            rewardTypeId: @rewardType.key()
            description: "He is helpful"
            issuer: @user.key()
            recipient: USER_ID
            rewardAmount: 100
        .then (@reward)=>
          App.route message()
        .then (reply)=>
          jreply = json(reply)
          jreply.should.match /Community A/i
          jreply.should.match /2: show awards list/
          @message = message('2')
          App.route @message
        .then (reply)=>
          @message.parts[0].should.match /\*AWARDS FOR Community A\*/
          @message.parts[0].should.match /\d{4}\s+❂ 100\s+\*Joe User\*\s+Super sweet award\s+_He is helpful_/
          jreply = json(reply)
          jreply.should.match /COMMUNITY A/
          jreply.should.match /Possible Awards/

      context 'projects#create', ->
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
              project_owner: USER_ID
              imageUrl: 'http://example.com/very-small.png'
              tasksUrl: 'http://jira.com'

  context 'rewardTypes', ->
    context 'rewardTypes#create', ->
      it "allows the user to create a rewardType within the current project", ->
        createUser
          name: USER_ID
          current_project: PROJECT_ID
          state: 'projects#show'
        .then (@user)=>
          createProject(name: PROJECT_ID)
        .then (@project)=> App.route message()
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
          size(db.projects[PROJECT_ID]['reward-types']).should.eq 1
          db.projects[PROJECT_ID]['reward-types']['Kitais'].should.deep.eq
            name: 'Kitais'
            suggestedAmount: '4000'

  context 'rewards', ->
    context 'rewards#create', ->
      rewardTypeId = 'a very special award'
      projectId = 'some project id'
      rewardType = (project)=>
        project.createRewardType
          name: rewardTypeId
          suggestedAmount: '888'

      it "allows an admin to award coins to a user", ->
        createUser
          name: USER_ID
          state: 'rewards#create'
          current_project: projectId
          slack_username: 'duke'
          btc_address: null
        .then (@user)=>
          createProject
            name: projectId
            project_owner: 'nobody'
        .then (@project)=>
          @project.fetch()
        .then (@project)=>
          @message = message('')
          App.route @message
        .then (reply)=>
          @project.get('project_owner').should.not.eq @user.get('name')
          json(@message.parts[0]).should.match /Only project administrators can award coins/i
          @project.set 'project_owner', @user.key()
          @project.save()
        .then (@project)=>
          App.route message('')
        .then (reply)=>
          json(reply).should.match /5: send an award/
          App.route message('5')
        .then (reply)=>
          json(reply).should.match /Which slack @user should I send the reward to/i
          @message = message('@duke')
          App.route @message
        .then (reply)=>
          @message.parts[0].should.match /Sending a message to have @duke register a bitcoin address./
          @user.set 'btc_address', 'i am a bitcoin address'
        .then (@user)=>
          App.route @message
        .then (reply)=>
          json(reply).should.match /What award type\?/
          json(reply).should.match /No award types, please create one/
          rewardType(@project)
        .then (@rewardType)=>
          App.route message('x')
        .then (reply)=>
          json(reply).should.match /5: send an award/
          App.route message('5')
        .then (reply)=>
          json(reply).should.match /Which slack @user should I send the reward to/i
          App.route message('@duke')
        .then (reply)=>
          json(reply).should.match /What award type\?/
          json(reply).should.match /a very special award.+888/
          App.route message('A')
        .then (reply)=>
          json(reply).should.match /How much do you want to reward @duke for \\"a very special award\\"/i
          App.route message('4000')
        .then (reply)=>
          json(reply).should.match /What was the contribution @duke made for the award/i
          @message = message('was awesome')
          App.route @message

        .then (reply)=>
          @firebaseServer.getValue()
        .then (db)=>
          # project -> award -> reward(key: timestamp, issuer, repic, amount, rewardType)
          rewards = db.projects[projectId].rewards
          reward = values(rewards)[0]
          reward.name.should.match /[0-9-:Z]+/
          delete reward.name
          reward.should.deep.eq
            issuer: USER_ID
            recipient: 'slack:1234'
            rewardAmount: '4000'
            rewardTypeId: @rewardType.key()
            description: 'was awesome'
            projectId: "some project id"

      it "shows good error message if user isn't in the db, and pms the user", ->
        createUser
          name: USER_ID
          state: 'rewards#create'
          current_project: projectId
          slack_username: 'duke'
          btc_address: 'i am a bitcoin address'
        .then (@user)=>
          createProject
            name: projectId
            project_owner: @user.key()
        .then (@project)=>
          App.route message('')
        .then (reply)=>
          App.route message('5')
        .then (reply)=>
          @message = message('@not_a_slack_user')
          App.route @message
        .then (reply)=>
          @message.parts[0].should.match /The user @not_a_slack_user is not recognized. Sending them a message now./
          App.sendMessage.deliveries['not_a_slack_user'].length.should.eq 1
          App.sendMessage.deliveries['not_a_slack_user'][0].should.match /Hi! @.+ is trying to send you project coins for 'some project id'. In order to receive project coin awards please tell me your bitcoin address./

  context 'error states', ->
    it "resets a user's state if they route with an invalid state", ->
      createUser
        name: USER_ID
        state: 'invalid#state'
      .then (@user)=>
        @message = message('')
        App.route @message
      .then (reply)=>
        @user.fetch()
      .then (@user)=>
        @user.get('state').should.eq User::initialState

  context 'fallback text', ->
    context 'projects#index', ->

      beforeEach ->
        createUser
          name: USER_ID
          state: 'projects#index'
          has_interacted: true
          btc_address: '3HNSiAq7wFDaPsYDcUxNSRMD78qVcYKicw'
        .then (@user)=>
          createProject(name: "Community A")
        .then (@project)=>

      it "contains fallback text", ->
        @user.save()
        .then (@user)=> App.route message()
        .then (reply)=> App.route message()
        .then (reply)=>
          type(reply).should.eq 'array'
          reply.length.should.eq 2
          reply[0].fallback.should.match /Contribute to projects and receive project coins/

          reply[1].fallback.should.match /Choose a Project/
          reply[1].fallback.should.match /Community A/

          reply[1].fallback.should.match /Your Project Coins/
          reply[1].fallback.should.match /FinTechHacks ❂ 456/
          reply[1].fallback.should.match /bitcoin address: 3HNSiAq7wFDaPsYDcUxNSRMD78qVcYKicw/

          reply[1].fallback.should.match /Actions/
          reply[1].fallback.should.match /create your project/
          reply[1].fallback.should.match /set your bitcoin address/

      # TODO: loop over controller actions
        # fallback text not empty
