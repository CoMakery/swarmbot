{ assign, partition, sortByOrder, forEach, map } = require 'lodash'
Proposal = require '../models/proposal'

# TODO: Factor a Collection class out of this class.
class ProposalCollection
  constructor: (modelsOrSnapshot, options={})->
    @parent = options.parent
    if modelsOrSnapshot instanceof Array
      @models = modelsOrSnapshot
    else
      @snapshot = modelsOrSnapshot
      @models = for id, data of @snapshot.val()
        new Proposal assign(data, id: id), { parent: @parent }

  getReputationScores: ->
    @map (p) -> p.getReputationScore()

  sortByReputationScore: ->
    # have to partition because sorting puts undefined scores at the top.
    [score, noScore] = partition @models, (proposal) -> proposal.get('reputationScore')?

    sorted = sortByOrder(score, [(p) -> p.get('reputationScore')], ['desc'])
    @models = sorted.concat(noScore)
    @

  isEmpty: ->
    length = if @snapshot? then @snapshot.numChildren() else @models.length
    (length == 0)

  each: (cb)->
    forEach @models, cb

  map: (cb)->
    map @models, cb

module.exports = ProposalCollection
