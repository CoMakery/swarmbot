{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class HomeView extends ZorkView
  constructor: (@dco, @proposals) ->
    @menu = {}

    # TODO: top 5 proposals only
    i = 1
    for proposal in @proposals.all()
      @menu[i++] = @proposalMenuItem proposal

    # @menu[i++] = { text: "More", transition: 'index' }
    @menu[i++] = { text: "Create a proposal", transition: 'create' }
    @menu[i++] = { text: "More commands", transition: 'more' }

  render: ->
    """
    *#{if @proposals.isEmpty() then 'No proposals' else 'Proposals'} in #{@dco.get 'id'}*
    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

  proposalMenuItem: (proposal) ->
    {
      text: @proposalMessage(proposal)
      data: { id: proposal.get('id') }
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
