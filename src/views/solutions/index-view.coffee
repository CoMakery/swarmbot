{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class IndexView extends ZorkView
  constructor: (@proposal) ->
    @menu = {}
    i = 1

    @proposal.solutions().sortByVotes().each (solution) =>
      @menu[i++] =
        text: solution.key()
        transition: 'show'
        data: { solutionId: solution.key(), proposalId: solution.parent.key() }

    @menu[i++] = { text: "Submit a solution", transition: 'create', data: {proposalId: @proposal.key()} }
    @menu.b = { text: "Back", transition: 'exit', data: {proposalId: @proposal.key()} }

  render: ->
    """
    *#{if @proposal.solutions().isEmpty() then 'No solutions' else 'Solutions'} for #{@proposal.key()}*

    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

module.exports = IndexView
