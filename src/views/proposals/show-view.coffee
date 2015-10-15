{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class ShowView extends ZorkView
  constructor: (@proposal) ->
    @menu = {
      1: { text: "Vote Up", command: 'voteUp' }
      2: { text: "Vote Down", command: 'voteDown' }
      3:
        text: "Submit Solution",
        transition: 'createSolution'
        data: { proposalId: @proposal.get('id') }
      x: { text: "Exit", transition: 'exit' }
    }

  render: ->

    """
    *Proposal: #{@proposal.get('id')}*
    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

module.exports = ShowView
