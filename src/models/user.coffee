{log, p, pjson} = require 'lightsaber'
swarmbot = require '../models/swarmbot'
{ values } = require 'lodash'

class User

  constructor: ({@userRef}) ->

  @find: (userKey) ->
    users = swarmbot.firebase().child('users')
    new User userRef: users.child(userKey)

  register: (myKey, value) ->
    p "key", myKey
    p "v", value
    newHash= ""
    newHash[myKey] = value
    @userRef.update newHash

module.exports = User
