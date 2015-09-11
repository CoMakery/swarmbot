# Description:
#   Because I want to govern myself
#
# Dependencies:
#   None
#
# Commands:
#
# NYI Commands:
#
#   hubot what what
#   hubot x marks the what
#   hubot tag <dco_name> <tag>
#   hubot info <dco_name>

# Author:
#   fractastical

{log, p, pjson} = require 'lightsaber'
swarmbot        = require '../models/swarmbot'

module.exports = (robot) ->
  # robot.brain.data.bounties or= {}

  # unless Config.adminList()
  #   robot.logger.warning 'HUBOT_TEAM_ADMIN environment variable not set'

  robot.respond /list proposals?.*/i, (msg) ->

      dcoKey = 'save-the-world'
      proposals = swarmbot.firebase().child('projects/' + dcoKey + '/proposals')
      MAX_MESSAGES_FOR_SLACK = 10
      proposals.orderByKey()
        .limitToFirst(MAX_MESSAGES_FOR_SLACK)
        .on 'child_added', (snapshot) ->
          msg.send snapshot.val().name + " | votes: 0"

      #TODO: awesome trust-exchange stuff could go here, showing votes/endorsements for a specific proposal

  robot.respond /propose (.+)$/i, (msg) ->

    msg.match.shift()
    [proposalName] = msg.match
    dcoKey = 'save-the-world'
    dcoProposalStatus = {stage: 1}
    proposalRef = swarmbot.firebase().child('projects/' + dcoKey + '/proposals')
    proposalRef.push( {"name" : proposalName, "author" : robot.whose msg })
    msg.send "Proposal added"
