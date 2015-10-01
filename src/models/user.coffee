{log, p, pjson} = require 'lightsaber'
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

  # constructor: ({@userRef}) ->
  # @find: (userKey) ->
  #   users = swarmbot.firebase().child('users')
  #   new User userRef: users.child(userKey)
  # register: (myKey, value) ->
  #   newHash= {}
  #   newHash[myKey] = value
  #   @userRef.update newHash

module.exports = User
