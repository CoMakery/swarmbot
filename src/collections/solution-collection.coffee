{log, p, pjson} = require 'lightsaber'
{ sortByOrder } = require 'lodash'
FirebaseCollection = require './firebase-collection'
Solution = require '../models/solution'

class SolutionCollection extends FirebaseCollection
  model: Solution

  sortByVotes: ->
    @models = sortByOrder @models, [
        (p) -> isNaN(p.get('totalVotes'))
        (p) -> p.get('totalVotes')
      ],
      ['asc', 'desc']
    @

module.exports = SolutionCollection
