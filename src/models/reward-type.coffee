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
      @sendAsset = Promise.promisify(=> colu.sendAsset(arguments...))
      @project = @parent
      @hostAmount = 0
      hostAwardPromise = if process.env.HOST_BTC_ADDRESS && process.env.HOST_PERCENTAGE? && process.env.HOST_PERCENTAGE > 0
        @hostAmount = amount * process.env.HOST_PERCENTAGE * .01
        @sendAsset @sendAssetArgs
          address: process.env.HOST_BTC_ADDRESS
          amount: @hostAmount
      else
        Promise.resolve()
    .then =>
      @sendAsset @sendAssetArgs
        address: btcAddress
        amount: amount - @hostAmount

  sendAssetArgs: ({address, amount})->
    args =
      from: [ @project.get('coluAssetAddress') ]
      to: [{
        assetId: @project.get('coluAssetId')
        address
        amount
      }]
      metadata:
        project: @project.get('name')
        rewardType: @get('name')
    debug pjson sendAssetArgs: args
    args

module.exports = RewardType
