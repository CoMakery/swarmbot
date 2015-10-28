{ log, p, pjson } = require 'lightsaber'
{ isEmpty } = require 'lodash'
ZorkView = require '../zork-view'

class ShowView extends ZorkView
  constructor: (@solution) ->
    @menu = {}
    i = 1

    @menu[i++] =
      text: "Vote Up"
      command: 'upvote'
      data: { solutionId: @solution.get('id'), proposalId: @solution.parent.get('id') }

    @menu[i++] =
      text: "Send Reward"
      command: 'sendReward'
      data:
        solutionId: @solution.get('id')
        proposalId: @solution.parent.get('id')

    @menu.x = { text: "Exit", transition: 'exit' }

  render: ->
    """
    *Solution: #{@solution.get('id')}*
    #{@solution.get('link')}

    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

module.exports = ShowView
