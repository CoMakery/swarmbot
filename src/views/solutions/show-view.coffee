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
      data: { solutionId: @solution.key(), proposalId: @solution.parent.key() }

    @menu[i++] =
      text: "Send Reward"
      transition: 'sendReward'
      data:
        solutionId: @solution.key()
        proposalId: @solution.parent.key()

    @menu.b = { text: "Back", transition: 'exit' }

  render: ->
    """
    *Solution: #{@solution.key()}*
    #{@solution.get('link')}

    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

module.exports = ShowView
