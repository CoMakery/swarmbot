debug = require('debug')('app')
{log, p, pjson} = require 'lightsaber'
StateMachine = require 'javascript-state-machine'
Promise = require 'bluebird'
FirebaseModel = require './firebase-model'
swarmbot = require './swarmbot'

class User extends FirebaseModel
  urlRoot: 'users'
  initialState: 'general#home'

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

  setDcoTo: (dcoKey) ->
    @set "current_dco", dcoKey

  canUpdate: (dco) ->
    dco.get('project_owner') == @get('id')

  fetch: ->
    super().then =>
      @current = @get('state') || @initialState
      @

  onafterevent: (event, from, to, data) ->
    debug "// Transition #{from} -> #{to} // Event #{event} // Data: #{data} //"
    @set('state', to)
    # TODO: stat: user entering what state

  StateMachine.create
    target: @prototype
    error: (event, from, to, args, errorCode, errorMessage) ->
      console.error "state machine error! event: #{event} // #{from} -> #{to} // args: #{pjson args} // error: #{errorCode}  #{errorMessage}"

    events: [
      { name: 'show', from: 'general#home', to: 'proposals#show' }
      { name: 'exit', from: 'proposals#show', to: 'general#home' }

      { name: 'create', from: 'general#home', to: 'proposals#create' }
      { name: 'exit', from: 'proposals#create', to: 'general#home' }

      { name: 'setBounty', from: 'proposals#show', to: 'proposals#edit' }
      { name: 'exit', from: 'proposals#edit', to: 'proposals#show' }

      { name: 'createSolution', from: 'proposals#show', to: 'solutions#create' }

      { name: 'solutions', from: 'proposals#show', to: 'solutions#index' }
      { name: 'exit', from: 'solutions#index', to: 'proposals#show' }

      { name: 'show', from: 'solutions#index', to: 'solutions#show' }
      { name: 'exit', from: 'solutions#show', to: 'solutions#index' }

      { name: 'create', from: 'solutions#index', to: 'solutions#create' }
      { name: 'exit', from: 'solutions#create', to: 'solutions#index' }

      { name: 'sendReward', from: 'solutions#show', to: 'solutions#sendReward' }
      { name: 'exit', from: 'solutions#sendReward', to: 'solutions#show' }

      { name: 'more', from: 'general#home', to: 'general#more' }
      { name: 'exit', from: 'general#more', to: 'general#home' }

      { name: 'setDco', from: 'general#more', to: 'users#setDco' }
      { name: 'exit', from: 'users#setDco', to: 'general#home' }

      { name: 'myAccount', from: 'general#more', to: 'users#myAccount' }
      { name: 'exit', from: 'users#myAccount', to: 'general#home' }

      { name: 'setBtc', from: 'users#myAccount', to: 'users#setBtc' }
      { name: 'exit', from: 'users#setBtc', to: 'users#myAccount' }

    ]

module.exports = User
