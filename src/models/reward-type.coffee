{log, p, pjson} = require 'lightsaber'
{ size } = require 'lodash'
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

  awardTo: (btcAddress, amount)=>
    swarmbot.colu()
    .then (colu)=>
      project = @parent
      recipients = if process.env.HOST_BTC_ADDRESS && process.env.HOST_PERCENTAGE
        hostAmount = amount * process.env.HOST_PERCENTAGE * .01

        [
          {
            address: btcAddress
            assetId: project.get('coluAssetId')
            amount: amount - hostAmount
          }
          {
            address: process.env.HOST_BTC_ADDRESS
            assetId: project.get('coluAssetId')
            amount: hostAmount
          }
        ]
      else
        [{
          address: btcAddress
          assetId: project.get('coluAssetId')
          amount: amount
        }]

      args =
        from: [ project.get('coluAssetAddress') ]
        to: recipients
        metadata:
          project: project.get('name')
          rewardType: @get('name')

      Promise.promisify(=> colu.sendAsset(arguments...))(args)

module.exports = RewardType
