{ log, p, pjson } = require 'lightsaber'

class HomeMenuView
  constructor: (@proposals) ->

  # {
  #   1: {
  #     text: "Proposal xyz"
  #     object: {id: 'this is a proposal'}
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

  build: ->
    @items = {}

    # TODO: top 5 proposals
    @items[1] = @proposalMenuItem( @proposals.get(0) )

    @items[6] = { text: "More", transition: 'index' }
    @items['x'] = { text: "Exit", transition: 'exit' }
    @

  render: ->
    lines = for i, menuItem of @items
      "#{i}: #{menuItem.text}"
    lines.join("\n")

  proposalMenuItem: (proposal) ->
    {
      text: @proposalMessage(proposal)
      object: { id: proposal.get('id') }
      transition: 'show'
    }

  proposalMessage: (proposal) ->
    text = "#{proposal.get('id')}"
    # text += " Reward #{proposal.get('amount')}" if proposal.get('amount')?
    score = proposal.ratings().score()
    text += " Rating: #{score}%" unless isNaN(score)
    # text += " (awarded)" if proposal.get('awarded')?
    text

module.exports = HomeMenuView
