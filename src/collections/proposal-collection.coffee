{log, p, pjson} = require 'lightsaber'
{ assign, partition, sortByOrder, forEach, map } = require 'lodash'
FirebaseCollection = require './firebase-collection'
Proposal = require '../models/proposal'

class ProposalCollection extends FirebaseCollection
  model: Proposal

  sortByVotes: ->
    @models = sortByOrder @models, [
        (p) -> isNaN(p.get('totalVotes'))
        (p) -> p.get('totalVotes')
      ],
      ['asc', 'desc']
    @

module.exports = ProposalCollection
