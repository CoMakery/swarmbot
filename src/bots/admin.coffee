# Description:
#   Informational and help related commands
#
# Commands:
#  hubot admin commands

# Hidden Commands:

#   hubot x marks the what
#   hubot hello
#  hubot fork me

# Not in use:
#   hubot tag <community name> <tag>
#   hubot info <community name>

# Propz:
#   raysrashmi for https://github.com/raysrashmi/hubot-instagram
#

{log, p, pjson} = require 'lightsaber'
{ values } = require 'lodash'
{ Claim } = require 'trust-exchange'
swarmbot = require '../models/swarmbot'
Proposal = require '../models/proposal'
DCO = require '../models/dco'
ProposalsController = require '../controllers/proposals-controller'

module.exports = (robot) ->

  robot.respond /admin commands$/i, (msg) ->
    #TODO: This should pull from wizard or some other repo where all the comamnds live
    msg.send "Admin commands work for owner only:\naward <bounty name> bounty to <username>"

  robot.respond /award\s+(.+)\s+to\s+(.+?)(?:\s+in (.+))?\s*$/i, (msg) ->
    [all, proposalName, awardee, dcoKey] = msg.match
    log "MATCH 'award proposal' : #{pjson msg.match}"
    new ProposalsController().award(msg, { proposalName, awardee, dcoKey })
