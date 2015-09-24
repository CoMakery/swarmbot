{log, p, pjson} = require 'lightsaber'
chai = require 'chai'
chai.should()
sinon = require 'sinon'
Helper = require 'hubot-test-helper'

swarmbot = require '../src/models/swarmbot'
DCO = require '../src/models/dco'
User = require '../src/models/user'
UsersController = require '../src/controllers/users-controller'

sinon.stub(swarmbot, 'colu').returns
  on: ->
  init: ->
  sendAsset: ->
  issueAsset: ->

# call this only after stubbing:
helper = new Helper '../src/bots'

process.env.EXPRESS_PORT = 8901  # don't conflict with hubot console port 8080
process.env.FIREBASE_URL = 'https://dazzle-staging.firebaseio-demo.com/'

describe 'swarmbot', ->

  beforeEach -> @room = helper.createRoom()
  afterEach -> @room.destroy()

  context 'Identity', ->

  context 'DCO bounty', ->
    xit 'a DCO can create a bounty', (done) ->
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
    xit 'an admin can award a bounty', (done) ->
      bountyName = 'plant a tree'
      dcoKey = 'save-the-world'
      bountyParams = {
        dcoKey
        bountyName
      }
      dco = DCO.find dcoKey
      dco.awardBounty bountyParams, (error, message) ->
          done()
