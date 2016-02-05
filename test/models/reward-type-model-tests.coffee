{ createUser } = require '../helpers/test-helper'
sinon = require 'sinon'
Mitm = require 'mitm'
{ p } = require 'lightsaber'

swarmbot = require '../../src/models/swarmbot'
RewardType = require '../../src/models/reward-type'
User = require '../../src/models/user'
Project = require '../../src/models/project'
KeenioInfo = require '../../src/services/keenio-info.coffee'

describe 'RewardType', ->
  describe 'awardTo', ->
    beforeEach ->
      swarmbot.colu.restore?()

      sinon.stub(swarmbot, 'colu').returns Promise.resolve
        on: ->
        init: ->
        sendAsset: sinon.spy()
        issueAsset: ->

      @project = new Project(name: "project")
      @rewardType = new RewardType(name: "reward", { parent: @project })

    context "when HOST_PERCENTAGE is set", ->
      beforeEach ->
        process.env.HOST_BTC_ADDRESS = "host_btc"
        process.env.HOST_NAME = "hostname"
        process.env.HOST_PERCENTAGE = 1.5

      afterEach ->
        process.env.HOST_BTC_ADDRESS = null
        process.env.HOST_NAME = null
        process.env.HOST_PERCENTAGE = null

      it "sends a percentage of the reward to HOST_BTC_ADDRESS and the rest to the recipient", ->
        @rewardType.awardTo("address", 1000)
        swarmbot.colu().then (colu)->
          recipients = colu.sendAsset.getCall(0).args[0].to
          recipients.should.deep.eq [
            {address: "address", amount: 985, assetId: undefined}
            {address: "host_btc", amount: 15, assetId: undefined}
          ]

    context "when HOST_PERCENTAGE is not set", ->
      it "sends the entire reward to the recipient", ->
        process.env.HOST_BTC_ADDRESS = null
        process.env.HOST_NAME = null
        process.env.HOST_PERCENTAGE = null

        @rewardType.awardTo("address", 1000)
        swarmbot.colu().then (colu)->
          recipients = colu.sendAsset.getCall(0).args[0].to
          recipients.should.deep.eq [
            {address: "address", amount: 1000, assetId: undefined}
          ]

