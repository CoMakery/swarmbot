{ log, p, pjson } = require 'lightsaber'

class HomeView
  # {
  #   1: {
  #     text: "Proposal xyz"
  #     data: {id: 'this is a proposal'}
  #     transition: 'show'
  #   }
  #   6: {
  #     text: "More"
  #     transition: 'index'
  #   }
  #   x: {
  #     text: "Exit"
  #     transition: 'exit'
  #   }
  #   help: {
  #     command: 'homeHelp'
  #   }
  # }

  constructor: (@proposals) ->
    @menu = {}

    # TODO: top 5 proposals
    for proposal, i in @proposals.models
      @menu[i+1] = @proposalMenuItem proposal

    @menu[i+1] = { text: "More", transition: 'index' }
    @menu[i+2] = { text: "Create a proposal", transition: 'create' }

  render: ->
    lines = for i, menuItem of @menu
      "#{i}: #{menuItem.text}"
    """
    *Top Proposals*
    #{lines.join("\n")}

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
    # text += " Reward #{proposal.get('amount')}" if proposal.get('amount')?
    score = proposal.ratings().score()
    text += " Rating: #{score}%" unless isNaN(score)
    # text += " (awarded)" if proposal.get('awarded')?
    text

module.exports = HomeView
