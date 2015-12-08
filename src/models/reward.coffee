{log, p, pjson} = require 'lightsaber'
{ size } = require 'lodash'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
FirebaseModel = require './firebase-model'
RatingCollection = require '../collections/rating-collection'

class Reward extends FirebaseModel
  hasParent: true
  urlRoot: "rewards"

module.exports = Reward
