sinon = require 'sinon'
{ createUser, createProject, message } = require '../helpers/test-helper'
{ keys } = require 'lodash'
{log, p, pjson} = require 'lightsaber'

ApplicationStateController = require '../../src/controllers/application-state-controller'
User = require '../../src/models/user'

describe 'ApplicationStateController', ->
  beforeEach (done)=>
    createUser
      state: "some#state"
      stateData: {foo: 'bar'}
      menu: {foo: 'bar'}
    .then (@currentUser)=>
      msg = message '', { @currentUser }
      @controller = new ApplicationStateController msg
      done()

  describe "#render", =>
    describe 'when the view has a menu defined', =>
      it "saves the user's menu", =>
        view = {render: sinon.spy(), menu: "this is a menu"}
        @controller.render(view)
        .then =>
          view.render.should.have.been.called
          @currentUser.get('menu').should.eq "this is a menu"

    describe 'when the view does NOT have a menu defined', =>
      it "just renders", =>
        @currentUser.get('menu').should.deep.eq {foo: 'bar'}

        view = {render: sinon.spy()}
        @controller.render(view)
        .then =>
          view.render.should.have.been.called
          @currentUser.get('menu').should.deep.eq {foo: 'bar'}

  describe '#execute', =>
    context "when transition is not defined on user", =>
      beforeEach (done)=>
        @controller.execute {transition: 'does-not-exist'}
        .then ->
          done()

      it "should reset user's state to default", =>
        @currentUser.get('state').should.eq User::initialState

      it "should reset user's menu", =>
        menu = @currentUser.get('menu')
        keys(menu).should.contain("1")

      it "should reset user's state data", =>
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
