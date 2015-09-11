{log, p, pjson} = require 'lightsaber'
swarmbot = require '../models/swarmbot'
{ values } = require 'lodash'

class User

  constructor: ({@userRef}) ->

  @find: (userKey) ->
    users = swarmbot.firebase().child('users')
    new Users userRef: users.child(userKey)


module.exports = User
