# Description:
#   Reputation hubot commands
#
# Dependencies:
#   None
#
# Commands:
#   hubot create <currecy_name> bank X coins - create bank called <bounty_name> with X coins
#   hubot list currencies - list all existing currencies
#   hubot send X bank <bank_name> to <recipient> - send bank

Config          = require './models/config'
Reputation      = require './models/reputation'
ResponseMessage = require './helpers/response_message'
UserNormalizer  = require './helpers/user_normalizer'

module.exports = (robot) ->
  Reputation.robot = robot

  ##
  ##   hubot show reputation of <person> -
  ##
  robot.respond /show reputation of (.*)/i, (msg) ->

    person = msg.match[1]
    msg.send Reputation.get person
