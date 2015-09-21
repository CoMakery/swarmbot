{log, p, pjson} = require 'lightsaber'
Backbone = require '../../vendor/backbonefire'
swarmbot = require '../models/swarmbot'
{ values } = require 'lodash'

class User extends Backbone.Firebase.Model
  urlRoot: process.env.FIREBASE_URL + '/users'
  autoSync: true
  
  # constructor: ({@userRef}) ->

  # @find: (userKey) ->
  #   users = swarmbot.firebase().child('users')
  #   new User userRef: users.child(userKey)

  # register: (myKey, value) ->
  #   newHash= {}
  #   newHash[myKey] = value
  #   @userRef.update newHash

module.exports = User
