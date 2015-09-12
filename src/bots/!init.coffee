{ json, log, p, pjson } = require 'lightsaber'

# Description:
#   Initialize the bot
#
# Commands:
#

InitBot = (robot) ->
  robot.whose = (message) -> "@#{message.message.user.name}"

  robot.respond /what data\?$/i, (msg) ->
    p msg
    msg.send pjson msg.user

module.exports = InitBot
