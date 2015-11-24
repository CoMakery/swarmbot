{ log, p, pjson } = require 'lightsaber'

class SendRewardView
  constructor: ({@data, @recipientUsername}) ->
    @menu = {}
    @menu[0] =
      text: "back"
      transition: 'exit'
      data: { proposalId: @data.proposalId, solutionId: @data.solutionId }

  render: ->
    @question "Enter reward amount to send to #{@recipientUsername}
      for the solution '#{@data.solutionName}'
      ('0' to go back)"

module.exports = SendRewardView
