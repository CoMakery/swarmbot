{log, p, pjson} = require 'lightsaber'
FirebaseCollection = require './firebase-collection'
Reward = require '../models/reward'

class RewardCollection extends FirebaseCollection
  model: Reward

module.exports = RewardCollection