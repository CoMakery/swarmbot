# Description:
#   Create a bounty
#
# Commands:
#   hubot I'd like <suggested improvement for swarmbot>

# Hidden Commands:
#   hubot create proposal <proposal name> for <number of coins> [in <community>]
#   hubot rate <proposal name> <value>% [in <community name]
#   hubot award proposal <proposal name> to <slack username> [in <community>]
#   hubot show proposal <proposal name> [in <community name>]


# Not in use:
#   hubot list bounties [in <community name>]
#   hubot (<bounty_name>) bounty add me - add me to the bounty
#   hubot get balance - get your current balance
#   hubot (<bounty_name>) bounty add (me|<user>) - add me or <user> to bounty
#   hubot (<bounty_name>) bounty add (me|<user>) - add me or <user> to bounty
#   hubot (<bounty_name>) bounty remove (me|<user>) - remove me or <user> from bounty
#   hubot (<bounty_name>) bounty (empty|clear) - clear bounty list
#   hubot (delete|remove) <bounty_name> bounty - delete bounty called <bounty_name>
#   hubot (<bounty_name>) bounty -1 - remove me from the bounty
#   hubot (<bounty_name>) bounty count - list the current size of the bounty
#   hubot (<bounty_name>) bounty (list|show) - list the people in the bounty

{log, p, pjson} = require 'lightsaber'
{ values } = require 'lodash'
{ Claim } = require 'trust-exchange'
swarmbot = require '../models/swarmbot'
Proposal = require '../models/proposal'
DCO = require '../models/dco'
ProposalsController = require '../controllers/proposals-controller'

module.exports = (robot) ->

  App.respond /i(?:[’']d| would) like\s+(.+)$/i, (msg) ->
    suggestion = msg.match[1]
    log "MATCH 'i'd like' : #{pjson msg.match}"
    new ProposalsController().swarmbotSuggestion(msg, { suggestion })

  robot.respond /:\+1:\s+(.+)\s*$/i, (msg) ->
    [all, proposalName] = msg.match
    rating = 95
    community = undefined
    log "MATCH 'upvote' : #{all}"
    new ProposalsController().rate(msg, { community, proposalName, rating })

  robot.respond /bounties$/i, (msg) ->
    new ProposalsController().listApproved(msg, { })

  robot.respond /proposals$/i, (msg) ->
    new ProposalsController().list(msg, { })
    msg.send "type 'upvote <proposal_name>' if you think it should be approved"
