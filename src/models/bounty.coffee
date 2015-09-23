Promise = require 'bluebird'
FirebaseModel = require './firebase-model'

class Bounty extends FirebaseModel
  hasParent: true
  urlRoot: "bounties"
  # constructor: ({@bountyRef}) ->

  # get: (property, cb) ->
  #   @bountyRef.child(property).on 'value', (snapshot) -> cb snapshot.val()

module.exports = Bounty
