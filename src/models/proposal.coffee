{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
FirebaseModel = require './firebase-model'
Solution = require './solution'
RatingCollection = require '../collections/rating-collection'
SolutionCollection = require '../collections/solution-collection'
{ Reputation, Claim } = require 'trust-exchange'

class Proposal extends FirebaseModel
  hasParent: true
  urlRoot: "proposals"

  @find: (id, { parent }) ->
    proposal = new Proposal({id: id}, parent: parent)
    proposal.fetch()

  upvote: Promise.promisify (user, cb) ->
    attributes = {}
    attributes[user.get 'id'] = 1
    @firebase().child('votes').update attributes, cb

  createSolution: (attrs)->
    # id & link
    solution = new Solution(attrs, {parent: @})
    solution.save()

  solutions: ->
    @_solutions ?= new SolutionCollection @snapshot.child('solutions'), parent: @

  # getReputationScore: ->
  #   return Promise.resolve(null) unless @get('id')?
  #   Reputation.score @get('id'),
  #     firebase: path: @firebasePath()
  #   .then (score) =>
  #     @attributes.reputationScore = score if score?
  #     @

  ratings: ->
    @_ratings ?= new RatingCollection @snapshot.child('ratings'), parent: @

  awardTo: Promise.promisify (btcAddress, cb) ->
    colu = swarmbot.colu()
    dco = @parent
    args =
      from: [ dco.get('coluAssetAddress') ]
      to: [{
        address: btcAddress
        assetId: dco.get('coluAssetId')
        amount: @get('amount')
      }]
      metadata:
        community: dco.get('id')
        proposal:  @get('id')

    colu.sendAsset args, cb

module.exports = Proposal
