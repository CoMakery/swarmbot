{log, p, pjson, json} = require 'lightsaber'
{values, size} = require 'lodash'
Promise = require 'bluebird'
require '../helpers/testHelper'
global.App = require '../../src/app'
ColuInfo = require '../../src/services/colu-info'
Project = require '../../src/models/project'
User = require '../../src/models/user'
RewardType = require '../../src/models/reward-type'
nock = require 'nock'
sinon = require 'sinon'
InitBot = require '../../src/bots/!init'

userId = "slack:1234"

message = (input)->
  @parts = []
  {
    parts: @parts
    match: [null, input]
    send: (reply)=> throw new Error "deprecated, use pmReply"
    message:
      user:
        name: 'frank'
        id: userId
        real_name: 'Frank Herbert'
        email_address: 'frank@herbert.com'
    robot:
      whose: (msg)-> userId
      messageRoom: ->
      pmReply: (msg, attachment)=>
        reply = attachment.text or attachment
        @parts.push reply
  }

describe 'swarmbot', ->
  context 'projects', ->
    context 'projects#show', ->
      it "shows the user's current project", ->
        projectId = 'Your Great Project'
        new User(name: userId, current_project: projectId, state: 'projects#show').save()
        .then (@user) =>
        @project = new Project
          name: projectId
          project_owner: userId
          tasksUrl: 'http://example.com'
        @project.save()
        .then (@project)-> @project.createRewardType name: 'Do Stuff'
        .then -> @project.createRewardType name: 'Be Glorious'
        .then -> App.route message()
        .then (reply)->
          jreply = json reply
          jreply.should.match /See Project Tasks/
          jreply.should.match /example\.com/
          jreply.should.match /Do stuff/i
          jreply.should.match /Be glorious/i
          jreply.should.match /\d: create an award/i

    context 'projects#index', ->
      sinon.stub(ColuInfo.prototype, 'balances').returns Promise.resolve [
        {
          name: 'FinTechHacks'
          assetId: 'xyz123'
          balance: 456
        }
      ]

      beforeEach ->
        @user = new User(name: userId, state: 'projects#index', has_interacted: true)

      it "shows a welcome screen if there are no projects", ->
        @user.save()
        .then (@project)=> App.route message()
        .then (reply)=>
          jreply = json(reply)
          jreply.should.match /Welcome friend!/
          jreply.should.match /Let's get started.*Type 1/
          App.route message('1')
        .then (reply)=>
          json(reply).should.match /What is the name of this project/

      it "shows a welcome screen if the user has never made contact", ->
        @user.set 'has_interacted', false
        .then (@user)=> new Project(name: "Community A").save()
        .then (@user)=> App.route message()
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
          new Project(name: "Community A").save()
          new Project(name: "Community B").save()
          new Project(name: "Community C").save()
        ]
        .then =>
          App.route message()
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

      it "shows the list of rewards", ->
        user = new User
          name: userId
          slack_username: "joe"
          real_name: 'Joe User'
          state: 'projects#show'
          current_project: "Community A"
          has_interacted: true
        user.save()
        .then (@user)=>
          new Project(name: "Community A").save()
        .then (@project)=>
          @project.createRewardType(name: "Super sweet award", suggestedAmount: 100)
        .then (@rewardType)=>
          @project.createReward
            rewardTypeId: @rewardType.key()
            description: "He is helpful"
            issuer: user.key()
            recipient: userId
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
              project_owner: userId
              imageUrl: 'http://example.com/very-small.png'
              tasksUrl: 'http://jira.com'

  context 'rewardTypes', ->
    context 'rewardTypes#create', ->
      it "allows the user to create a rewardType within the current project", ->
        projectId = 'Your Great Project'
        @user = new User(name: userId, current_project: projectId, state: 'projects#show').save()
        project = new Project(name: projectId)
        project.save()
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
          size(db.projects[projectId]['reward-types']).should.eq 1
          db.projects[projectId]['reward-types']['Kitais'].should.deep.eq
            name: 'Kitais'
            suggestedAmount: '4000'

  context 'rewards', ->
    context 'rewards#create', ->
      rewardTypeId = 'a very special award'
      projectId = 'a project'
      user = ->
        new User
          name: userId
          state: 'rewards#create'
          stateData: {}
          current_project: projectId
          slack_username: 'duke'
          btc_address: 'i am a bitcoin address'
        .save()
      project = ->
        new Project
          name: projectId
          project_owner: 'nobody'
        .save()
      rewardType = (project)=>
        project.createRewardType
          name: rewardTypeId
          suggestedAmount: '888'

      it "allows an admin to award coins to a user", ->
        user()
        .then (@user)=> project()
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
          App.route message('@duke')
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
            issuer: userId
            recipient: 'slack:1234'
            rewardAmount: '4000'
            rewardTypeId: @rewardType.key()
            description: 'was awesome'
            projectId: "a project"

      it "resets a user's state if they route with an invalid state", ->
        new User
          name: userId
          state: 'invalid#state'
          stateData: {}
        .save()
        .then (@user)=>
          @message = message('')
          App.route @message
        .then (reply)=>
          @user.fetch()
        .then (@user)=>
          @user.get('state').should.eq User::initialState
