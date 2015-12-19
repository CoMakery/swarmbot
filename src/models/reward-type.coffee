{log, p, pjson} = require 'lightsaber'
{ size } = require 'lodash'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
FirebaseModel = require './firebase-model'
RatingCollection = require '../collections/rating-collection'

class RewardType extends FirebaseModel
  hasParent: true
  urlRoot: "rewardTypes"

  upvote: (user)->
    @attributes.votes ?= {}
    @attributes.votes[user.key()] = 1
    @attributes.totalVotes = size @attributes.votes
    @save()

  rewards: ->
    @parent.rewards()

  ratings: ->
    @_ratings ?= new RatingCollection @snapshot.child('ratings'), parent: @

  awardTo: Promise.promisify (btcAddress, amount, cb)->
    swarmbot.colu().then (colu)=>
      project = @parent
      args =
        from: [ project.get('coluAssetAddress') ]
        to: [{
          address: btcAddress
          assetId: project.get('coluAssetId')
          amount: amount
        }]
        metadata:
          project: project.get 'name'
          rewardType: @get 'name'

      try
        colu.sendAsset args, cb
      catch error
        cb(error)

module.exports = RewardType
