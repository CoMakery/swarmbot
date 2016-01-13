{log, p, pjson} = require 'lightsaber'
request = require 'request-promise'
StateMachine = require 'javascript-state-machine'
FirebaseModel = require './firebase-model'
swarmbot = require './swarmbot'
Project = require '../models/project.coffee'

class User extends FirebaseModel
  urlRoot: 'users'
  initialState: 'projects#index'

  newRecord: -> not @get("slackUsername")?

  @findBySlackUsername: Promise.promisify (slackUsername, cb)->
    swarmbot.firebase().child('users') # TODO: use urlRoot here
      .orderByChild('slackUsername')
      .equalTo(slackUsername)
      .limitToFirst(1)
      .once 'value', (snapshot)->
        return cb(new Promise.OperationalError("The user '@#{slackUsername}' is not recognized.")) unless snapshot.val()
        userId = Object.keys(snapshot.val())[0]
        cb(null, new User({}, snapshot: snapshot.child(userId)))
    , cb # error

  @setupToReceiveBitcoin: (sender, receiverSlackUserName, data, sendPm)->
    User.findBySlackUsername receiverSlackUserName
    .error (error)=>
      slackUser = App.slack.getUserByName(receiverSlackUserName)
      if slackUser
        user = new User
          name: "slack:#{slackUser.id}"
          state: 'users#setBtc'
        user.save()
        .then =>
          slackUser['name'] = receiverSlackUserName
          App.registerUser(user, slackUser, true)
        .then =>
          Promise.reject(Promise.OperationalError("The user @#{receiverSlackUserName} is not recognized. Sending them a message now."))
      else
        sendPm "Sorry, @#{receiverSlackUserName} doesn't look like a user."
        null

    .then (recipient)=>
      return unless recipient?
      data.recipient = recipient.key()
      unless recipient.get('btcAddress')?
        throw Promise.OperationalError("Sending a message to have @#{receiverSlackUserName} register a bitcoin address.")
    .error (error)=>
      App.sendMessage(receiverSlackUserName, "Hi! @#{sender.get("slackUsername")} is trying to send you project coins for '#{sender.get('currentProject')}'. In order to receive project coin awards please tell me your bitcoin address.")
      throw error

  setProjectTo: (projectKey)->
    @set "currentProject", projectKey

  canUpdate: (project)->
    project.get('projectOwner') == @key()

  fetch: ->
    super().then =>
      @current = @get('state') || @initialState
      @

  onafterevent: (event, from, to, data)->
    debug "// Transition #{from} -> #{to} // Event #{event} // Data: #{data} //"
    @set('state', to)
    # TODO: stat: user entering what state

  reset: ->
    @update
      state: User::initialState
      stateData: {}
      menu: {}

  StateMachine.create
    target: @prototype
    error: (event, from, to, args, errorCode, errorMessage)->
      debug "State Machine Error! Event: #{event} // #{from} -> #{to} // args: #{pjson args} // error: #{errorCode}  #{errorMessage}"
      @reset()

    events: [
      { name: 'exit', from: User::initialState, to: User::initialState }

      { name: 'show', from: 'projects#show', to: 'rewardTypes#show' }
      { name: 'exit', from: 'rewardTypes#show', to: 'projects#show' }

      { name: 'create', from: 'projects#show', to: 'rewardTypes#create' }
      { name: 'exit', from: 'rewardTypes#create', to: 'projects#show' }

      { name: 'rewardsList', from: 'projects#show', to: "projects#rewardsList" }
      { name: 'exit', from: 'projects#rewardsList', to: "projects#show" }

      { name: 'setBounty', from: 'rewardTypes#show', to: 'rewardTypes#edit' }
      { name: 'exit', from: 'rewardTypes#edit', to: 'rewardTypes#show' }

      { name: 'rewards', from: 'rewardTypes#show', to: 'rewards#index' }
      { name: 'exit', from: 'rewards#index', to: 'rewardTypes#show' }

      { name: 'show', from: 'rewards#index', to: 'rewards#show' }
      { name: 'exit', from: 'rewards#show', to: 'rewards#index' }

      { name: 'create', from: 'rewards#index', to: 'rewards#create' }
      { name: 'exit', from: 'rewards#create', to: 'rewards#index' }

      { name: 'sendReward', from: 'projects#show', to: 'rewards#create' }
      { name: 'exit', from: 'rewards#create', to: 'projects#show' }

      { name: 'setProject', from: 'projects#show', to: 'projects#index' }
      { name: 'exit', from: 'projects#index', to: 'projects#show' }

      { name: 'create', from: 'projects#index', to: 'projects#create' }
      { name: 'exit', from: 'projects#create', to: 'projects#index' }
      { name: 'showProject', from: 'projects#create', to: 'projects#show'}

      { name: 'myAccount', from: 'projects#show', to: 'users#myAccount' }
      { name: 'exit', from: 'users#myAccount', to: 'projects#show' }

      { name: 'setBtc', from: 'projects#index', to: 'users#setBtc' }
      { name: 'exit', from: 'users#setBtc', to: 'projects#index' }

    ]

module.exports = User
