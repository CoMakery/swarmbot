{ assign, partition, sortByOrder, forEach, map } = require 'lodash'
FirebaseCollection = require './firebase-collection'
Proposal = require '../models/proposal'

class ProposalCollection extends FirebaseCollection
  model: Proposal

  getReputationScores: ->
    @map (p) -> p.getReputationScore()

  sortByReputationScore: ->
    # have to partition because sorting puts undefined scores at the top.
    [score, noScore] = partition @models, (proposal) -> proposal.get('reputationScore')?

    sorted = sortByOrder(score, [(p) -> p.get('reputationScore')], ['desc'])
    @models = sorted.concat(noScore)
    @

module.exports = ProposalCollection
