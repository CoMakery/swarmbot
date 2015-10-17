{ log, p, pjson } = require 'lightsaber'
{ isEmpty } = require 'lodash'
ZorkView = require '../zork-view'

class ShowView extends ZorkView
  constructor: (@proposal) ->
    @menu = {}
    i = 1

    @menu[i++] =
      text: "Vote Up"
      command: 'upvote'
      data: { proposalId: @proposal.get('id') }

    @menu[i++] =
      text: "Solutions",
      transition: 'solutions'
      data: { proposalId: @proposal.get('id') }

    @menu[i++] =
      text: "Submit Solution",
      transition: 'createSolution'
      data: { proposalId: @proposal.get('id') }
    @menu.x = { text: "Exit", transition: 'exit' }

  render: ->
    description = if isEmpty @proposal.get('description')
      ''
    else
      "_#{@proposal.get('description')}_\n"
    """
    *Proposal: #{@proposal.get('id')}*
    #{description}
    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

module.exports = ShowView
