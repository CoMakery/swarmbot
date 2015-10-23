# Description:
#   Informational and help related commands
#
# Commands:

# Hidden Commands:

#  hubot x marks the what
#  hubot hello
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
AdminController = require '../controllers/admin-controller'
ProposalsController = require '../controllers/proposals-controller'

module.exports = (robot) ->

  App.respond /admin$/i, (msg) ->

    # msg.send "Data about your community: X Members; X open propsals; Y bounties claimed"
    #TODO: This should pull from wizard or some other repo where all the comamnds live
    msg.send "Admin commands work for owner only:\naward <bounty name> to <username>\nstats\nset coin name <currency_name>"
    #TODO: add: set budget <budget amount>

  App.respond /award\s+(.+)\s+to\s+(.+?)(?:\s+in (.+))?\s*$/i, (msg) ->
    [all, proposalName, awardee, dcoKey] = msg.match
    log "MATCH 'award' : #{pjson msg.match}"
    new ProposalsController().award(msg, { proposalName, awardee, dcoKey })

  App.respond /set coin name\s+(.+)\s*$/i, (msg) ->
    [all, coinName, dcoKey] = msg.match
    new AdminController().setCoinName(msg, { coinName, dcoKey })

  App.respond /constitute\s+(.+)\s*$/i, (msg) ->
    [all, constitutionLink, dcoKey] = msg.match
    new AdminController().constitute(msg, { constitutionLink, dcoKey })

  App.respond /stats$/i, (msg) ->
    [all] = msg.match
    new AdminController().stats(msg)

  #
  #   log "MATCH 'create asset' : #{all}"
  #   new DcosController().issueAsset(msg, { dcoKey, amount })
  #
  # App.respond /settings$/i, (msg) ->
  #   [all] = msg.match
  #   log "MATCH 'settings' : #{pjson msg.match}"
  #   msg.send "Set currency <currency>
