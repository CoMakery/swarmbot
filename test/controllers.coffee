{log, p, pjson} = require 'lightsaber'
chai = require 'chai'
chai.should()
sinon = require 'sinon'
Helper = require 'hubot-test-helper'

User = require '../src/models/user'
UsersController = require '../src/controllers/users-controller'

process.env.EXPRESS_PORT = 8901  # don't conflict with hubot console port 8080
process.env.FIREBASE_URL = 'https://dazzle-staging.firebaseio-demo.com/'

helper = new Helper '../src/bots'

describe 'controllers', ->

  beforeEach -> @room = helper.createRoom()
  afterEach -> @room.destroy()

  context 'UsersController', ->
    it 'user can register a bitcoin address', (done) ->
      # slackUsername = 'slack_username'
      btcAddress = '12afeafeaefeaee'
      myUser = new User(id: 'henry')
      mock = sinon.mock(myUser)
      mock.expects("set").withArgs("btc_address", btcAddress)
      controller = new UsersController()
      mock = sinon.stub controller, "currentUser", -> myUser
      msg = sinon.stub()
      controller.registerBtc @room, {btcAddress}
      done()
