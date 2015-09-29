{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
FirebaseModel = require './firebase-model'
{ Reputation, Claim } = require 'trust-exchange'

class Proposal extends FirebaseModel
  hasParent: true
  urlRoot: "proposals"
  @find: (id, { parent }) ->
    new Proposal({id: id}, parent: parent)

  getReputationScore: ->
    return Promise.resolve(null) unless @get('id')?
    Reputation.score @get('id'),
      firebase: path: @firebasePath()
    .then (score) =>
      @attributes.reputationScore = score if score?
      @

module.exports = Proposal
