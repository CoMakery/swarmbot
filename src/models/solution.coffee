{log, p, pjson} = require 'lightsaber'
{ size } = require 'lodash'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
FirebaseModel = require './firebase-model'
RatingCollection = require '../collections/rating-collection'

class Solution extends FirebaseModel
  hasParent: true
  urlRoot: "solutions"

  upvote: (user) ->
    @attributes.votes ?= {}
    @attributes.votes[user.key()] = 1
    @attributes.totalVotes = size @attributes.votes
    @save()

module.exports = Solution
