{log, p, pjson} = require 'lightsaber'
FirebaseModel = require './firebase-model'
RatingCollection = require '../collections/rating-collection'

class Rating extends FirebaseModel
  hasParent: true
  urlRoot: "ratings"

module.exports = Rating
