{log, p, pjson} = require 'lightsaber'
{ assign, partition, sortByOrder, forEach, map } = require 'lodash'
FirebaseCollection = require './firebase-collection'
Proposal = require '../models/proposal'

class ProposalCollection extends FirebaseCollection
  model: Proposal

  getReputationScores: ->
    @map (p) -> p.getReputationScore()

  sortByReputationScore: ->
    @models = sortByOrder @models, [
        (p) -> isNaN(p.ratings().score())
        (p) -> p.ratings().score()
      ],
      ['asc', 'desc']
    @

module.exports = ProposalCollection
