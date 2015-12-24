{ createUser } = require '../helpers/test-helper'
User = require '../../src/models/user'

describe 'User', ->
  describe 'newRecord', ->
    it "returns true if slackUsername is set", ->
      createUser
        slackUsername: 'bob'
      .then (@user)=>
        @user.newRecord().should.eq true
      (new User(name: 'foo')).newRecord().should.eq false

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
