# Description:
#   Because I want to govern myself
#
# Commands:
#   hubot list proposals
#   hubot propose <proposal>

{log, p, pjson} = require 'lightsaber'
swarmbot        = require '../models/swarmbot'
DCO = require '../models/dco'

module.exports = (robot) ->

  robot.respond /list proposals(?: in (.+))?\s*$/i, (msg) ->
    [all, community] = msg.match
    new ProposalsController().list(msg, { community })

  robot.respond /propose\s+(.+)\s+(?: in\s+(.+))?\s*$/i, (msg) ->
    [all, proposalName, community] = msg.match
    new ProposalsController().create(msg, { bountyName, 0, community })

  robot.respond /vote\s+(.+)\s+([\d.]+)%(?:\s+(?:in|for)\s+(.*))?\s*$/i, (msg) ->
    [all, proposalName, rating, community] = msg.match
    new ProposalsController().rate(msg, { community, proposalName, rating })
