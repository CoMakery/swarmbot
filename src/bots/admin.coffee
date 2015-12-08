# Description:
#   Informational and help related commands
#
# Commands:
# hubot award <task name> to <username>

{log, p, pjson} = require 'lightsaber'
{ values } = require 'lodash'
swarmbot = require '../models/swarmbot'
Proposal = require '../models/proposal'
DCO = require '../models/dco'
AdminController = require '../controllers/admin-controller'

module.exports = (robot)->

  App.respond /admin$/i, (msg)->

    # msg.send "Data about your community: X Members; X open propsals; Y bounties claimed"
    #TODO: This should pull from wizard or some other repo where all the comamnds live
    msg.send "Admin commands work for owner only:\naward <task name> to <username>\nstats\nset coin name <currency_name>"
    #TODO: add: set budget <budget amount>

  App.respond /set coin name\s+(.+)\s*$/i, (msg)->
    [all, coinName, dcoKey] = msg.match
    new AdminController().setCoinName(msg, { coinName, dcoKey })

  App.respond /constitute\s+(.+)\s*$/i, (msg)->
    [all, constitutionLink, dcoKey] = msg.match
    new AdminController().constitute(msg, { constitutionLink, dcoKey })

  App.respond /stats$/i, (msg)->
    [all] = msg.match
    new AdminController().stats(msg)
