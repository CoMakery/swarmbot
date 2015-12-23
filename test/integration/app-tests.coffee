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
    it 'calls keen.io api to increment user count', ->
      spy = sinon.spy(KeenioInfo::, 'createUser')

      createUser(name: 'bob')
      .then (@bob)=>
        App.registerUser(@bob, {
          message:
            user:
              name: 'bob'
              email_address: 'bob@example.com'
        })
      .then => spy.should.have.been.calledWith @bob
