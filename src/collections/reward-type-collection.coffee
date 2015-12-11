{log, p, pjson} = require 'lightsaber'
FirebaseCollection = require './firebase-collection'
RewardType = require '../models/reward-type'

class RewardTypeCollection extends FirebaseCollection
  model: RewardType

module.exports = RewardTypeCollection
