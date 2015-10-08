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


  setDco: (dcoKey) ->
    @set "current_dco", dcoKey

  canUpdate: (dco) ->
    dco.get('owner') == @get('id')

  fetch: ->
    super().then =>
      @current = @get('state')
      @

  onafterevent: (event, from, to, data) ->
    p "#{event} : #{from} -> #{to} :: #{pjson data}"
    @set('state', to)
    # also set data here

  StateMachine.create
    target: @prototype
    events: [
      { name: 'proposals', from: 'none', to: 'proposals' }
      { name: 'exit', from: 'proposals', to: 'none' }
      { name: 'index', from: 'proposals', to: 'proposals-index' }
      { name: 'exit', from: 'proposals-index', to: 'proposals' }
      { name: 'create', from: 'proposals', to: 'proposals-create' }
      { name: 'exit', from: 'proposals-create', to: 'proposals' }
      { name: 'show', from: 'proposals-index', to: 'proposals-show' }
      { name: 'exit', from: 'proposals-show', to: 'proposals-index' }
      { name: 'createSolution', from: 'proposals-show', to: 'solutions-create' }
      { name: 'solutions', from: 'proposals-show', to: 'solutions-index' }
      { name: 'show', from: 'solutions-index', to: 'solutions-show' }
    ]

module.exports = User
