# Description:
#   Initialize the bot
#
# Commands:
#

trustExchange = require('trust-exchange').instance
trustExchange.configure()

InitBot = (robot) ->
  throw new Error if robot.whose?
  robot.whose = (message) -> "@#{message.message.user.name}"

module.exports = InitBot
