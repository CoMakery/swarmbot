{log, p, pjson} = require 'lightsaber'
{ assign, partition, sortByOrder, forEach, map, round, sum } = require 'lodash'
FirebaseCollection = require './firebase-collection'
Rating = require '../models/rating'

class RatingCollection extends FirebaseCollection
  model: Rating

  score: ->
    ratingValues = @map (model)-> model.get('value')
    round( sum(ratingValues) / @size() * 100 )

module.exports = RatingCollection
