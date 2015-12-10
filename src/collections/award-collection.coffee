{log, p, pjson} = require 'lightsaber'
FirebaseCollection = require './firebase-collection'
Award = require '../models/award'

class AwardCollection extends FirebaseCollection
  model: Award

module.exports = AwardCollection
