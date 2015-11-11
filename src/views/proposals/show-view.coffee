{ log, p, pjson } = require 'lightsaber'
{ isEmpty } = require 'lodash'
ZorkView = require '../zork-view'

class ShowView extends ZorkView
  constructor: (@proposal, { canSetBounty }) ->
    @menu = {}
    i = 1

    @menu[i++] =
      text: "Vote Up"
      command: 'upvote'
      data: { proposalId: @proposal.key() }

    @menu[i++] =
      text: "View All Solutions",
      transition: 'solutions'
      data: { proposalId: @proposal.key() }

    @menu[i++] =
      text: "Submit Solution",
      transition: 'createSolution'
      data: { proposalId: @proposal.key() }

    if canSetBounty
      @menu[i++] =
        text: "Set Bounty",
        transition: 'setBounty'
        data: { proposalId: @proposal.key() }

    @menu.b = { text: "Back", transition: 'exit' }

  render: ->
    description = ''
    if not isEmpty @proposal.get('description')
      description += "_#{@proposal.get('description')}_\n"
    if amount = @proposal.get 'amount'
      description += "Bounty: #{amount}\n"
    if imageUrl = @proposal.get 'imageUrl'
      description += "Image: #{imageUrl}\n"

    """
    *Proposal: #{@proposal.get 'name'}*
    #{description}
    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

module.exports = ShowView
