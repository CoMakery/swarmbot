{log, p, pjson} = require 'lightsaber'
chai = require 'chai'
chai.should()
sinon = require 'sinon'
# nock = require 'nock'
Helper = require 'hubot-test-helper'

swarmbot = require '../src/models/swarmbot'
DCO = require '../src/models/dco'

sinon.stub(swarmbot, 'colu').returns
  on: ->
  init: ->

# sinon.stub(swarmbot, 'firebase')

# call this only after stubbing:
helper = new Helper '../src/bots'

process.env.EXPRESS_PORT = 8901  # don't conflit with hubot console port 8080
process.env.FIREBASE_URL = 'https://dazzle-staging.firebaseio-demo.com/'

describe 'swarmbot', ->

  beforeEach -> @room = helper.createRoom()
  afterEach -> @room.destroy()

  context 'DCO asset', ->
    it 'user can create an asset for an existing dco', ->
      @room.user.say 'alice', '@hubot create 2000 of asset for save-the-world'
      @room.messages.should.deep.equal [
        ['alice', '@hubot create 2000 of asset for save-the-world']
        ['hubot', 'asset created']
      ]
      # check that the asset exists -- in fb/colu

  context 'DCO bounty', ->
    it 'a DCO can create a bounty', (done) ->
      amount = Math.round Math.random() * Math.pow 10, 16
      bountyName = 'plant a tree'
      dcoKey = 'save-the-world'
      bountyParams = {
        dcoKey
        bountyName
        amount
      }
      DCO.createBountyFor bountyParams, (error, message) ->
        message.should.equal 'bounty created'
        dco = DCO.find dcoKey
        dco.getBounty({bountyName}).get 'amount', (value) ->
          value.should.equal amount
          done()

  context 'dco admin can award bounty to user', ->
    @timeout 60000

    it 'an admin can award a bounty', (done) ->
      bountyName = 'plant a tree'
      dcoKey = 'save-the-world'
      bountyParams = {
        dcoKey
        bountyName
      }
      dco = DCO.find dcoKey
      dco.awardBounty bountyParams, (error, message) ->
          done()
