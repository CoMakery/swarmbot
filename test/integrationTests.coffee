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

  context 'help', ->
    it "returns top-level help"
    it "returns specific help based on user's state"
