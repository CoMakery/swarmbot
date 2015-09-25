Promise = require 'bluebird'
FirebaseModel = require './firebase-model'

class Bounty extends FirebaseModel
  hasParent: true
  urlRoot: "bounties"
  @find: (id, { parent }) ->
    new Bounty({id: id}, parent: parent)

module.exports = Bounty
