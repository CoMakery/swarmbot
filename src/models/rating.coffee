{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
FirebaseModel = require './firebase-model'
RatingCollection = require '../collections/rating-collection'

class Rating extends FirebaseModel
  hasParent: true
  urlRoot: "ratings"

module.exports = Rating
