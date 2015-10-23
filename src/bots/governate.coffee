# Description:
#   Because I want to govern myself
#
# Commands:
#   hubot bounties
#   hubot proposals

# Hidden Commands:
#   hubot list all proposals
#   hubot list proposals

# Not ready:
#   hubot propose <proposal>

{log, p, pjson} = require 'lightsaber'
swarmbot        = require '../models/swarmbot'
DCO = require '../models/dco'
ProposalsController = require '../controllers/proposals-controller'
MembersController = require '../controllers/members-controller'

module.exports = (robot) ->

  robot.respond /bounties$/i, (msg) ->
    new ProposalsController().listApproved(msg, { })

  robot.respond /proposals$/i, (msg) ->
    new ProposalsController().list(msg, { })
    msg.send "type 'upvote <proposal_name>' if you think it should be approved"
