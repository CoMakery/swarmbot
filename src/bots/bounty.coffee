# Commands:
#   hubot I'd like <suggested improvement for swarmbot>

# Hidden Commands:
#   hubot create task <task name> for <number of coins> [in <community>]
#   hubot rate <task name> <value>% [in <community name]
#   hubot award task <task name> to <slack username> [in <community>]
#   hubot show task <task name> [in <community name>]

{log, p, pjson} = require 'lightsaber'
{ values } = require 'lodash'
swarmbot = require '../models/swarmbot'
Proposal = require '../models/proposal'
DCO = require '../models/dco'
ProposalsController = require '../controllers/proposals-controller'

module.exports = (robot)->

  App.respond /i(?:[’']d| would) like\s+(.+)$/i, (msg)->
    suggestion = msg.match[1]
    log "MATCH 'i'd like' : #{pjson msg.match}"
    new ProposalsController().swarmbotSuggestion(msg, { suggestion })

  App.respond /:\+1:\s+(.+)\s*$/i, (msg)->
    [all, proposalName] = msg.match
    rating = 95
    community = undefined
    log "MATCH 'upvote' : #{all}"
    new ProposalsController().rate(msg, { community, proposalName, rating })

  App.respond /bounties$/i, (msg)->
    new ProposalsController().listApproved(msg, { })

  App.respond /proposals$/i, (msg)->
    new ProposalsController().list(msg, { })
    msg.send "type 'upvote <proposal_name>' if you think it should be approved"
