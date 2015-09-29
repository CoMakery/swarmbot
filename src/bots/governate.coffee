# Description:
#   Because I want to govern myself
#
# Commands:
#   hubot list proposals
#   hubot propose <proposal>

{log, p, pjson} = require 'lightsaber'
swarmbot        = require '../models/swarmbot'
DCO = require '../models/dco'
ProposalsController = require '../controllers/proposals-controller'
MembersController = require '../controllers/members-controller'

module.exports = (robot) ->

  robot.respond /list members(?: in (.+))?\s*$/i, (msg) ->
    [all, community] = msg.match
    new MembersController().list(msg, { community })

  robot.respond /list proposals(?: in (.+))?\s*$/i, (msg) ->
    [all, community] = msg.match
    # new ProposalsController().list(msg, { community })
    new ProposalsController().listApproved(msg, { community })

  robot.respond /propose\s+(.+)(?:\s+in\s+(.+))?\s*$/i, (msg) ->
    [all, proposalName, community] = msg.match
    p "com", community
    p "pname", proposalName
    new ProposalsController().create(msg, { proposalName, 0, community })

  robot.respond /vote\s+(.+)\s+([\d.]+)%(?:\s+(?:in|for)\s+(.*))?\s*$/i, (msg) ->
    [all, proposalName, rating, community] = msg.match
    new ProposalsController().rate(msg, { community, proposalName, rating })
