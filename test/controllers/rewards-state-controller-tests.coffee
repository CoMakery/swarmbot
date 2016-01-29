{ createUser, createProject, createRewardType, message } = require '../helpers/test-helper'
{ p, json } = require 'lightsaber'
sinon = require 'sinon'
RewardsStateController = require '../../src/controllers/rewards-state-controller'
User = require '../../src/models/user'
Project = require '../../src/models/project'
RewardType = require '../../src/models/reward-type'
swarmbot = require '../../src/models/swarmbot'

describe 'RewardsStateController', ->
  controller = null
  currentUser = null
  recipient = null
  project = null
  msg = null
  rewardType = null

  beforeEach ->
    sinon.spy(App, 'pmReply')
    App.robot =
          adapter: {
            customMessage: ->
          }

  afterEach ->
    App.pmReply.restore?()

  setup = =>
    createUser()
    .then (@currentUser)=>
      createUser
        slackUsername: "Bob"
    .then (@recipient)=>
      createProject()
    .then (@project)=>
      project = @project
      createRewardType(@project)
    .then (@rewardType)=>
      currentUser = @currentUser
      recipient = @recipient
      msg = message('', {@currentUser})
      controller = new RewardsStateController(msg)
      rewardType = @rewardType

  describe "#sendReward", ->
    describe "when colu is down", ->
      beforeEach ->
        swarmbot.colu.restore?()
        sinon.stub(swarmbot, 'colu').returns Promise.resolve
          on: ->
          init: ->
          sendAsset: (x, cb)-> throw new Error("bang")
          issueAsset: ->

      it "sends error message", ->
        setup()
        .then =>
          controller.sendReward(recipient, rewardType, 111)
        .then =>
          App.pmReply.getCall(0).args[1].text.should.eq "Error awarding 'random reward' to Bob. Unable to complete the transaction.\nbang"
