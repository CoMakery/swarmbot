{log, p, pjson} = require 'lightsaber'
{ size } = require 'lodash'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
FirebaseModel = require './firebase-model'
Solution = require './solution'
RatingCollection = require '../collections/rating-collection'
SolutionCollection = require '../collections/solution-collection'

class Proposal extends FirebaseModel
  hasParent: true
  urlRoot: "proposals"

  upvote: (user)->
    @attributes.votes ?= {}
    @attributes.votes[user.key()] = 1
    @attributes.totalVotes = size @attributes.votes
    @save()

  createSolution: (attrs)->
    # id & link
    solution = new Solution(attrs, {parent: @})
    solution.save()

  solutions: ->
    @_solutions ?= new SolutionCollection @snapshot.child('solutions'), parent: @

  ratings: ->
    @_ratings ?= new RatingCollection @snapshot.child('ratings'), parent: @

  awardTo: Promise.promisify (btcAddress, amount, cb)->
    swarmbot.colu().then (colu)=>
      dco = @parent
      args =
        from: [ dco.get('coluAssetAddress') ]
        to: [{
          address: btcAddress
          assetId: dco.get('coluAssetId')
          amount: amount
        }]
        metadata:
          project: dco.key()
          proposal:  @key()

      try
        colu.sendAsset args, cb
      catch error
        cb(error)

module.exports = Proposal
