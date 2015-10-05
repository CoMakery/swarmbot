{log, p, pjson} = require 'lightsaber'
FirebaseCollection = require './firebase-collection'
DCO = require '../models/dco'

class DcoCollection extends FirebaseCollection
  model: DCO

module.exports = DcoCollection
