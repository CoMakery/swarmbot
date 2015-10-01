{log, p, pjson} = require 'lightsaber'
FirebaseCollection = require './firebase-collection'
User = require '../models/user'

class UserCollection extends FirebaseCollection
  model: User

module.exports = UserCollection
