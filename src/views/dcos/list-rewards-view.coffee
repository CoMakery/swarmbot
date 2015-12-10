{ compact, first } = require 'lodash'
{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'
moment = require 'moment'

class ListRewardsView extends ZorkView
  constructor: ({@awards, @rewards})->

  render: ->
    rewards = @rewards.map (reward)=>
      awardId = reward.get('awardId')
      award = @awards.find (award)-> award.key() is awardId

      [
        moment(reward.get('name'), moment.ISO_8601).format("MMM Do YYYY")
        "#{App.COIN} #{reward.get('rewardAmount')}"
        "*#{reward.recipientRealName}*"
        award.get('name')
        "_#{reward.get('description')}_"
      ].join("   ")
    .join("\n")

    """
      AWARDS
      #{rewards}
    """
module.exports = ListRewardsView
