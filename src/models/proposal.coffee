{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
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
    @_ratings ?= new RatingCollection @snapshot.child('ratings'), parent: @

  awardTo: (btcAddress) ->
    amount = @get('amount')
    colu = swarmbot.colu()
    p args =
      from: [ @parent.get('coluAssetAddress') ]
      to: [
        {
          address: btcAddress
          assetId: @parent.get('coluAssetId')
          amount: amount
        }
      ]
    colu.sendAsset args, (err, body) ->
      p "we made it", body
      if err
        p "err:", err
        return console.error "Error: #{err}"
      console.log 'Body: ', body

module.exports = Proposal
