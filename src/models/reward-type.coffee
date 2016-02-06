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
      hostAmount = 0
      if process.env.HOST_BTC_ADDRESS && process.env.HOST_PERCENTAGE
        hostAmount = amount * process.env.HOST_PERCENTAGE * .01
        args = @sendAssetArgs
          address: process.env.HOST_BTC_ADDRESS
          amount: hostAmount
        colu.sendAsset(args)

      args = @sendAssetArgs
        address: btcAddress
        amount: amount - hostAmount
      Promise.promisify(=> colu.sendAsset(arguments...))(args)

  sendAssetArgs: ({address, amount})->
    from: [ project.get('coluAssetAddress') ]
    to: [{
      assetId: project.get('coluAssetId')
      address
      amount
    }]
    metadata:
      project: project.get('name')
      rewardType: @get('name')

module.exports = RewardType
