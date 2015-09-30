{log, p, pjson} = require 'lightsaber'
FirebaseCollection = require './firebase-collection'
User = require '../models/User'

class UserCollection extends FirebaseCollection
  model: User

module.exports = UserCollection
