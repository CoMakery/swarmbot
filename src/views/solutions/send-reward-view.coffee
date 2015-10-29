{ log, p, pjson } = require 'lightsaber'

class SendRewardView
  constructor: ({@data, @recipientUsername}) ->
    @menu =
      x:
        text: "Exit"
        transition: 'exit'

  render: ->
    "Enter reward amount to send to #{@recipientUsername} for the solution '#{@data.solutionId}' ('x' to exit)"

module.exports = SendRewardView
