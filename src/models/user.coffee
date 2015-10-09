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
      p "state machine error! #{event} : #{from} -> #{to} :: #{args} : #{errorCode} : #{errorMessage}"
      @set('state', 'home')

    events: [
      { name: 'index', from: 'home', to: 'proposals-index' }
      { name: 'show', from: 'home', to: 'proposals-show' }
      { name: 'exit', from: 'proposals-index', to: 'home' }

      { name: 'create', from: 'proposals-index', to: 'proposals-create' }
      { name: 'exit', from: 'proposals-create', to: 'proposals-index' }

      { name: 'show', from: 'proposals-index', to: 'proposals-show' }
      { name: 'exit', from: 'proposals-show', to: 'proposals-index' }

      { name: 'createSolution', from: 'proposals-show', to: 'solutions-create' }
      { name: 'solutions', from: 'proposals-show', to: 'solutions-index' }
      { name: 'show', from: 'solutions-index', to: 'solutions-show' }
    ]

  # private class within User:
  class Menu
    clear: -> @items = {}

    set: (number, data) ->
      @items[number] = data

module.exports = User
