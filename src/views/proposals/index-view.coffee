# { log, p, pjson } = require 'lightsaber'
#
# class IndexView
#
#   constructor: (@proposals) ->
#     @menu = {}
#
#     for proposal, i in @proposals.models
#       @menu[i+1] = @proposalMenuItem proposal
#
#     @menu['x'] = { text: "Exit", transition: 'exit' }
#
#   render: ->
#     lines = for i, menuItem of @menu
#       "#{i}: #{menuItem.text}"
#
#     """
#     *Proposals*
#     #{lines.join("\n")}
#
#     """
#
#   proposalMenuItem: (proposal) ->
#     {
#       text: @proposalMessage(proposal)
#       data: { id: proposal.key() }
#       transition: 'show'
#     }
#
#   proposalMessage: (proposal) ->
#     text = "#{proposal.key()}"
#     # text += " Reward #{proposal.get('amount')}" if proposal.get('amount')?
#     score = proposal.ratings().score()
#     text += " Rating: #{score}%" unless isNaN(score)
#     # text += " (awarded)" if proposal.get('awarded')?
#     text
#
# module.exports = IndexView
