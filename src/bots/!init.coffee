# Description:
#   Initialize the bot.
#   Note: this file name starts with a special character in order to load first;
#   Hubot loads scripts in sorted order.
#
# Commands:
#

{ type, json, log, p, pjson } = require 'lightsaber'
trustExchange = require('trust-exchange').instance
swarmbot = require '../models/swarmbot'

trustExchange.configure
  adaptors:
    firebase: swarmbot.firebase()

InitBot = (robot) ->
  throw new Error if robot.whose?
  robot.whose = (message) -> "@#{message.message.user.name}"

module.exports = InitBot
