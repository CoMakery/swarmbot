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

  robot.respond /list\s+(all)?\s*proposals(?: in (.+))?\s*$/i, (msg) ->
    [all, showAll, community] = msg.match
    log "MATCH 'list proposals' : #{all}"
    if showAll?
      new ProposalsController().list(msg, { community })
    else
      new ProposalsController().listApproved(msg, { community })

  robot.respond /propose\s+(.+)(?:for\s+([\d.]+)).*?$/i, (msg) ->
    [all, proposalName, amount, community] = msg.match
    #TODO: move to a utility class or Firebase model
    strippedProposalName =  proposalName.replace(/[.\[\]!()$#]/g,"")
    proposalName = strippedProposalName
    p "proposalName", proposalName
    p "amount", amount
    log "MATCH 'propose' : #{all}"
    if amount == undefined
      amount = 0
    new ProposalsController().create(msg, { proposalName, amount, community })
  #
  # robot.respond /propose\s+(.+)(?:\s+for\s+\$(.+))?\s*$/i, (msg) ->
  #   [all, proposalName, amount, community] = msg.match
  #   log "MATCH 'propose' : #{all}"
  #   if amount == undefined
  #     amount = 0
  #   new ProposalsController().create(msg, { proposalName, amount, community })

  robot.respond /vote\s+(.+)\s+([\d.]+)%(?:\s+(?:in|for)\s+(.*))?\s*$/i, (msg) ->
    [all, proposalName, rating, community] = msg.match
    log "MATCH 'vote' : #{all}"
    new ProposalsController().rate(msg, { community, proposalName, rating })
