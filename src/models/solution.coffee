{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
FirebaseModel = require './firebase-model'
RatingCollection = require '../collections/rating-collection'
{ Reputation, Claim } = require 'trust-exchange'

class Solution extends FirebaseModel
  hasParent: true
  urlRoot: "solutions"

module.exports = Solution
