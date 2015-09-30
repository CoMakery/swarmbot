{log, p, pjson} = require 'lightsaber'
FirebaseModel = require './firebase-model'
swarmbot = require './swarmbot'

class User extends FirebaseModel
  urlRoot: 'users'

  @findBySlackUsername: (slackUsername)->
    new Promise (resolve, reject) ->
      swarmbot.firebase().child('users') # TODO: use urlRoot here
        .orderByChild('slack_username')
        .equalTo(slackUsername)
        .limitToFirst(1)
        .once 'value', (snapshot)->
          resolve( new User {}, snapshot: snapshot )


  setDco: (dcoKey) ->
    @set "current_dco", dcoKey

  # constructor: ({@userRef}) ->
  # @find: (userKey) ->
  #   users = swarmbot.firebase().child('users')
  #   new User userRef: users.child(userKey)
  # register: (myKey, value) ->
  #   newHash= {}
  #   newHash[myKey] = value
  #   @userRef.update newHash

module.exports = User
