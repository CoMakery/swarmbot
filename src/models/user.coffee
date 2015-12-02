debug = require('debug')('app')
{log, p, pjson} = require 'lightsaber'
{filter} = require 'lodash'
request = require 'request-promise'
StateMachine = require 'javascript-state-machine'
Promise = require 'bluebird'
FirebaseModel = require './firebase-model'
swarmbot = require './swarmbot'
DCO = require '../models/dco.coffee'

class User extends FirebaseModel
  urlRoot: 'users'
  initialState: 'dcos#index'

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

  setDcoTo: (dcoKey)->
    @set "current_dco", dcoKey

  canUpdate: (dco)->
    dco.get('project_owner') == @key()

  fetch: ->
    super().then =>
      @current = @get('state') || @initialState
      @

  onafterevent: (event, from, to, data)->
    debug "// Transition #{from} -> #{to} // Event #{event} // Data: #{data} //"
    @set('state', to)
    # TODO: stat: user entering what state

  balances: ->
    @allBalances().then (balances)->
      filter balances, (balance)-> balance.name?

  allBalances: ->
    new Promise (resolve, reject)=>
      uri = "#{swarmbot.coluExplorerUrl()}/api/getaddressinfo?address=#{@get('btc_address')}"
      debug uri
      request
        uri: uri
        json: true
      .then (data)=>
        Promise.map data.assets, (asset)->
          DCO.findBy 'coluAssetId', asset.assetId
          .then (dco)=>
            asset.name = dco.get('name')
            asset
          .catch =>
            asset
        .then (assets)=>
          resolve assets
          # each asset has a .balance, .name, .assetId
      .error (error)=>
        debug error.message
        Promise.reject(Promise.OperationalError("(Currently not available)"))

  StateMachine.create
    target: @prototype
    error: (event, from, to, args, errorCode, errorMessage)->
      throw new Error "State Machine Error! Event: #{event} // #{from} -> #{to} // args: #{pjson args} // error: #{errorCode}  #{errorMessage}"

    events: [
      { name: 'exit', from: User::initialState, to: User::initialState }

      { name: 'show', from: 'dcos#show', to: 'proposals#show' }
      { name: 'exit', from: 'proposals#show', to: 'dcos#show' }

      { name: 'create', from: 'dcos#show', to: 'proposals#create' }
      { name: 'exit', from: 'proposals#create', to: 'dcos#show' }

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

      { name: 'setDco', from: 'dcos#show', to: 'dcos#index' }
      { name: 'exit', from: 'dcos#index', to: 'dcos#show' }

      { name: 'create', from: 'dcos#index', to: 'dcos#create' }
      { name: 'exit', from: 'dcos#create', to: 'dcos#index' }
      { name: 'showDco', from: 'dcos#create', to: 'dcos#show'}

      { name: 'myAccount', from: 'dcos#show', to: 'users#myAccount' }
      { name: 'exit', from: 'users#myAccount', to: 'dcos#show' }

      { name: 'setBtc', from: 'users#myAccount', to: 'users#setBtc' }
      { name: 'exit', from: 'users#setBtc', to: 'users#myAccount' }

    ]

module.exports = User
