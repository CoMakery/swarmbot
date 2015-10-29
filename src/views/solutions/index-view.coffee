{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class IndexView extends ZorkView
  constructor: (@proposal) ->
    @menu = {}
    i = 1

    @proposal.solutions().each (solution) =>
      @menu[i++] =
        text: solution.get 'id'
        transition: 'show'
        data: { solutionId: solution.get('id'), proposalId: solution.parent.get('id') }

    @menu[i++] = { text: "Submit a solution", transition: 'create' }
    @menu.x = { text: "Exit", transition: 'exit', data: {id: @proposal.get('id')} }

  render: ->
    """
    *#{if @proposal.solutions().isEmpty() then 'No solutions' else 'Solutions'} for #{@proposal.get 'id'}*

    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

module.exports = IndexView
