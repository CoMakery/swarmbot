{log, p, pjson} = require 'lightsaber'
FirebaseModel = require './firebase-model'

class User extends FirebaseModel
  urlRoot: 'users'

  # constructor: ({@userRef}) ->
  # @find: (userKey) ->
  #   users = swarmbot.firebase().child('users')
  #   new User userRef: users.child(userKey)
  # register: (myKey, value) ->
  #   newHash= {}
  #   newHash[myKey] = value
  #   @userRef.update newHash

module.exports = User
