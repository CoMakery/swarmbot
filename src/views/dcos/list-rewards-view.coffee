{ compact } = require 'lodash'
{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class ListRewardsView extends ZorkView
  constructor: ({@rewards})->

  render: ->
    rewards = @rewards.map (reward)->
      reward.get('name')
    .join(", ")
    """
      AWARDS
      #{rewards}
    """

    return "coming soon..."

module.exports = ListRewardsView
