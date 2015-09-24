{log, p, pjson} = require 'lightsaber'
chai = require 'chai'
chai.should()
sinon = require 'sinon'
Helper = require 'hubot-test-helper'
Promise = require('bluebird')
require('sinon-as-promised')(Promise)

User = require '../src/models/user'
UsersController = require '../src/controllers/users-controller'

process.env.EXPRESS_PORT = 8901  # don't conflict with hubot console port 8080
process.env.FIREBASE_URL = 'https://dazzle-staging.firebaseio-demo.com/'

helper = new Helper '../src/bots'

describe 'controllers', ->

  beforeEach -> @room = helper.createRoom()
  afterEach -> @room.destroy()

  context 'UsersController', ->

    beforeEach ->
      @user = new User(id: 'henry')
      @controller = new UsersController()
      sinon.stub @controller, "currentUser", => @user

    context 'register()', ->
      it 'registers a user\'s information', ->
        fetch = sinon.stub().resolves(@user)
        sinon.stub @user, "fetch", fetch
        @room.message =
          user:
            id: 123
            real_name: 'George'
            email_address: 'porgey@puddinpie.com'
        @controller.register(@room).then =>
          console.log @room.messages

    context 'registerBtc()', ->
      it 'allows user to register a bitcoin address', (done) ->
        btcAddress = '12afeafeaefeaee'
        sinon.mock(@user).expects("set").withArgs("btc_address", btcAddress)
        @controller.registerBtc @room, {btcAddress}
        done()

    context 'setCommunity()', ->
      it 'sets the DCO on a user', (done)->
        community = "have-fun"
        sinon.mock(@user).expects("setDco").withArgs(community)
        @controller.setCommunity(@room, { community })
        done()
