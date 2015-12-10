{ compact, first } = require 'lodash'
{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'
moment = require 'moment'

class ListRewardsView extends ZorkView
  constructor: ({@proposals, @rewards})->

  render: ->
    rewards = @rewards.map (reward)=>
      proposalId = reward.get('proposalId')
      proposal = @proposals.find (proposal)-> proposal.key() is proposalId
      [
        moment(reward.get('name'), moment.ISO_8601).format("MMM Do YYYY")
        "❂ #{reward.get('rewardAmount')}"
        "*#{reward.recipientRealName}*"
        proposal.get('name')
        "_#{reward.get('description')}_"
      ].join("   ")
    .join("\n")

    """
      AWARDS
      #{rewards}
    """

module.exports = ListRewardsView
