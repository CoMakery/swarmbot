{ log, p, pjson } = require 'lightsaber'

class SendRewardView
  constructor: ({@data, @recipientUsername}) ->
    @menu =
      b:
        text: "Back"
        transition: 'exit'

  render: ->
    "Enter reward amount to send to #{@recipientUsername}
      for the solution '#{@data.solutionName}'
      ('b' to go back)"

module.exports = SendRewardView
