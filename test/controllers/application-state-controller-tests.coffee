{ keys } = require 'lodash'
sinon = require 'sinon'
{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
{ createUser, createProject, message } = require '../helpers/testHelper'
ApplicationStateController = require '../../src/controllers/application-state-controller'
User = require '../../src/models/user'

describe 'ApplicationStateController', ->

  describe '#execute', ->
    context "when transition is not defined on user", =>
      beforeEach =>
        @setup = =>
          createUser
            state: "some#state"
            stateData: {foo: 'bar'}
            menu: {foo: 'bar'}
          .then (@currentUser)=>
            msg = message '', { @currentUser }
            @controller = new ApplicationStateController msg
            @controller.execute {transition: 'does-not-exist'}
          .then =>
            @currentUser

      it "should reset user's state to default", =>
        @setup().then (@currentUser)=>
          @currentUser.get('state').should.eq User::initialState

      it "should reset user's menu", =>
        @setup().then (@currentUser)=>
          menu = @currentUser.get('menu')
          keys(menu).should.contain("1")

      it "should reset user's state data", =>
        @setup().then (@currentUser)=>
          @currentUser.get('stateData').should.deep.eq {}

  describe '#getProject', ->
    it "should tell users if the project can't be found and reset the user", ->
      createUser
        currentProject: "a project that doesn't exist"
      .then (@currentUser)=>
        msg = message('', { @currentUser })
        @controller = new ApplicationStateController(msg)
        @controller.getProject()
        .catch (error)=>
          error.message.should.match /Couldn\'t find current project with name "a project that doesn\'t exist"/
          @currentUser.get("state").should.eq User::initialState

    it "should tell users if there is no current project and reset the user", ->
      createUser
        currentProject: null
      .then (@currentUser)=>
        msg = message('', { @currentUser })
        @controller = new ApplicationStateController(msg)
        @controller.getProject()
        .catch (error)=>
          @currentUser.get("state").should.eq User::initialState

    it "returns the project", ->
      createProject
        name: "project"
      .then =>
      createUser
        currentProject: "project"
      .then (@currentUser)=>
        msg = message('', {@currentUser})
        @controller = new ApplicationStateController(msg)
        @controller.getProject()
        .then (returnedProject)=>
          returnedProject.key().should.eq "project"