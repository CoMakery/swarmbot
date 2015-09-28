Promise = require 'bluebird'
FirebaseModel = require './firebase-model'

class Proposal extends FirebaseModel
  hasParent: true
  urlRoot: "proposals"
  @find: (id, { parent }) ->
    new Proposal({id: id}, parent: parent)

module.exports = Proposal
