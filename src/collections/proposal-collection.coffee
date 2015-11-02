{log, p, pjson} = require 'lightsaber'
{ assign, partition, sortByOrder, forEach, map } = require 'lodash'
FirebaseCollection = require './firebase-collection'
Proposal = require '../models/proposal'

class ProposalCollection extends FirebaseCollection
  model: Proposal

  getReputationScores: ->
    @map (p) -> p.getReputationScore()  # method seems to not exist. bug: https://github.com/citizencode/swarmbot/issues/116

  sortByReputationScore: ->
    @models = sortByOrder @models, [
        (p) -> isNaN(p.ratings().score())
        (p) -> p.ratings().score()
      ],
      ['asc', 'desc']
    @

module.exports = ProposalCollection
