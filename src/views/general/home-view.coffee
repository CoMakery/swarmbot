{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class HomeView extends ZorkView
  constructor: (@dco, @proposals) ->
    @orderedMenu = []

    # TODO: top 5 proposals only
    i = 1
    for proposal in @proposals.all()
      @orderedMenu.push [i++, @proposalMenuItem proposal]

    @orderedMenu.push [null, { text: "\n*Actions:*" }]
    @orderedMenu.push [i++, { text: "Create a proposal", transition: 'create' }]
    @orderedMenu.push [i++, { text: "Cap table", command: 'capTable' }]
    @orderedMenu.push [i++, { text: "More commands", transition: 'more' }]

    @menu = {}
    for [key, menuItem] in @orderedMenu
      @menu[key] = menuItem if key?

  render: ->
    headline = if @proposals.isEmpty() then 'No proposals' else 'Proposals'
    headline += " in #{@dco.get 'id'}"
    """
    #{@bold headline}
    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

  proposalMenuItem: (proposal) ->
    {
      text: @proposalMessage(proposal)
      data: { proposalId: proposal.get('id') }
      transition: 'show'
    }

  proposalMessage: (proposal) ->
    text = "#{proposal.get('id')}"
    text += " (Bounty: #{proposal.get('amount')})" if proposal.get('amount')?
    # score = proposal.ratings().score()
    # text += " Rating: #{score}%" unless isNaN(score)
    # text += " (awarded)" if proposal.get('awarded')?
    text

module.exports = HomeView
