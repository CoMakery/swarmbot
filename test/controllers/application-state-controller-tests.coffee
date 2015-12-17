{ keys } = require 'lodash'
{log, p, pjson} = require 'lightsaber'
{ createUser, createProject, message } = require '../helpers/testHelper'
ApplicationStateController = require '../../src/controllers/application-state-controller'
User = require '../../src/models/user'
require '../helpers/testHelper'

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
            msg = message '', {@currentUser}
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
