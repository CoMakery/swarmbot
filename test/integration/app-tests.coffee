{ createUser } = require '../helpers/testHelper.coffee'
require '../../src/app.coffee'
User = require '../../src/models/user.coffee'
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
