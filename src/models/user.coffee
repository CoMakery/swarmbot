{log, p, pjson} = require 'lightsaber'
StateMachine = require 'javascript-state-machine'
Promise = require 'bluebird'
FirebaseModel = require './firebase-model'
swarmbot = require './swarmbot'

class User extends FirebaseModel
  urlRoot: 'users'

  @findBySlackUsername: Promise.promisify (slackUsername, cb)->
    swarmbot.firebase().child('users') # TODO: use urlRoot here
      .orderByChild('slack_username')
      .equalTo(slackUsername)
      .limitToFirst(1)
      .once 'value', (snapshot)->
        return cb(new Promise.OperationalError("Cannot find a user named '#{slackUsername}'.")) unless snapshot.val()
        userId = Object.keys(snapshot.val())[0]
        cb(null, new User({}, snapshot: snapshot.child(userId)))
    , cb # error

  constructor: (args...) ->
    super args...
    @menu = new Menu

  setDco: (dcoKey) ->
    @set "current_dco", dcoKey

  canUpdate: (dco) ->
    dco.get('owner') == @get('id')

  fetch: ->
    super().then =>
      @current = @get('state') || 'home'
      @

  onafterevent: (event, from, to, data) ->
    p "// Transition #{from} -> #{to} // Event #{event} // Data: #{data} //"
    @set('state', to)
    # also set data here

  StateMachine.create
    target: @prototype
    error: (event, from, to, args, errorCode, errorMessage) ->
      console.error "state machine error! event: #{event} // #{from} -> #{to} // args: #{pjson args} // error: #{errorCode}  #{errorMessage}"
      @set('state', 'home')

    events: [
      # { name: 'index', from: 'home', to: 'proposalsIndex' }
      { name: 'show', from: 'home', to: 'proposalsShow' }
      { name: 'exit', from: 'proposalsShow', to: 'home' }
      # { name: 'exit', from: 'proposalsIndex', to: 'home' }

      { name: 'create', from: 'home', to: 'proposalsCreate' }
      { name: 'exit', from: 'proposalsCreate', to: 'home' }

      # { name: 'create', from: 'proposalsIndex', to: 'proposalsCreate' }
      # { name: 'show', from: 'proposalsIndex', to: 'proposalsShow' }

      { name: 'createSolution', from: 'proposalsShow', to: 'solutionsCreate' }
      { name: 'exit', from: 'solutionsCreate', to: 'proposalsShow' }

      { name: 'solutions', from: 'proposalsShow', to: 'solutionsIndex' }
      { name: 'exit', from: 'solutionsIndex', to: 'proposalsShow' }

      { name: 'show', from: 'solutionsIndex', to: 'solutionsShow' }
      { name: 'exit', from: 'solutionsShow', to: 'solutionsIndex' }
    ]

  # private class within User:
  class Menu
    clear: -> @items = {}

    set: (number, data) ->
      @items[number] = data

module.exports = User
