{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
FirebaseModel = require './firebase-model'
RatingCollection = require '../collections/rating-collection'
{ Reputation, Claim } = require 'trust-exchange'

class Proposal extends FirebaseModel
  hasParent: true
  urlRoot: "proposals"
  @find: (id, { parent }) ->
    new Proposal({id: id}, parent: parent)

  # getReputationScore: ->
  #   return Promise.resolve(null) unless @get('id')?
  #   Reputation.score @get('id'),
  #     firebase: path: @firebasePath()
  #   .then (score) =>
  #     @attributes.reputationScore = score if score?
  #     @

  ratings: ->
    new RatingCollection @snapshot.child('ratings'), parent: @

module.exports = Proposal
