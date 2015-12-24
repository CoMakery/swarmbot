{ createUser } = require '../helpers/test-helper'
sinon = require 'sinon'
require '../../src/app.coffee'
User = require '../../src/models/user.coffee'
KeenioInfo = require '../../src/services/keenio-info.coffee'
Init = require '../../src/bots/!init'

describe "App", ->
  beforeEach ->
    @robot =
      enter: ->
      respond: ->
      adapter: {client: {}}

    @robot.whose = (msg)-> "slack:#{msg.message.user.id}"
    @robot.adapter.customMessage = ->
    App.robot = @robot

  describe ".greet", ->
    it "sets the user's state to the initial state", ->
      msg =
        robot: @robot
        message: { user: { id: "I am actually a human" } }
        parts: []
        match: {}

      App.greet(msg)
      .then =>
        User.find("slack:I am actually a human")
      .then (@createdUser)=>
        @createdUser.exists().should.eq true
        @createdUser.get('state').should.eq "projects#index"

  describe '.registerUser', ->
    beforeEach ->
      @spy = sinon.spy(KeenioInfo::, 'createUser')

    afterEach ->
      KeenioInfo::createUser.restore?()

    it 'does NOT call out to keen if it is an existing user', ->
      createUser(name: 'bob', slackUsername: null)
      .then (@bob)=>
        App.registerUser(@bob, {
          message:
            user:
              name: 'bob'
              email_address: 'bob@example.com'
        })
      .then => @spy.should.have.not.been.called

    it 'calls keen.io api to increment user count', ->
      createUser(name: 'bob', slackUsername: 'bob_yeah')
      .then (@bob)=>
        App.registerUser(@bob, {
          message:
            user:
              name: 'bob'
              email_address: 'bob@example.com'
        })
      .then => @spy.should.have.been.calledWith @bob
