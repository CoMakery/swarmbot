{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class SendRewardView extends ZorkView
  constructor: ({@data, @recipientUsername})->
    @menu = {}
    @menu.x =
      text: "back"
      transition: 'exit'
      data: { proposalId: @data.proposalId, solutionId: @data.solutionId }

  render: ->
    @question "Enter reward amount to send to #{@recipientUsername}
      for the solution '#{@data.solutionName}'
      ('x' to exit)"

module.exports = SendRewardView
