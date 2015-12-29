{ createUser } = require '../helpers/test-helper'
sinon = require 'sinon'
{ p } = require 'lightsaber'
User = require '../../src/models/user'
KeenioInfo = require '../../src/services/keenio-info.coffee'

describe 'User', ->
  describe 'newRecord', ->
    it "returns false if slackUsername is set", ->
      createUser
        slackUsername: 'bob'
      .then (@user)=>
        @user.newRecord().should.eq false
      (new User(name: 'foo')).newRecord().should.eq true

  describe 'events', ->
    context 'when executing an invalid state', ->
    it 'resets user state', ->
      createUser
        state: "some#state"
        stateData: {foo: 'bar'}
        menu: {foo: 'bar'}
      .then (@user)=>
        @user.exit()
        .then =>
          @user.get('state').should.eq User::initialState
          @user.get('stateData').should.deep.eq {}
          @user.get('menu').should.deep.eq {}

  describe '#reset', ->
    it 'resets user state, stateData, and menu', ->
      createUser
        state: "some#state"
        stateData: {foo: 'bar'}
        menu: {foo: 'bar'}
      .then (@user)=>
        @user.exit()
        .then =>
          @user.get('state').should.eq User::initialState
          @user.get('stateData').should.deep.eq {}
          @user.get('menu').should.deep.eq {}

  describe '#setupToReceiveBitcoin', ->
    beforeEach ->
      @spy = sinon.spy(KeenioInfo::, 'createUser')

    afterEach ->
      KeenioInfo::createUser.restore?()

    it 'should mark the user in Keen.io', ->
      sendPm = sinon.spy()
      App.robot = {
        messageRoom: -> {}
        adapter:
          client:
            getUserByName: (userName)-> {}
      }
      createUser(name: 'admin', slackUsername: 'adminUserName')
      .then (@admin)=>
        User.setupToReceiveBitcoin(@admin, 'someGuy', {}, sendPm)
      .error => @spy.should.have.been.called