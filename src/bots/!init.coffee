# Description:
#   Initialize the bot
#
# Commands:
#

InitBot = (robot) ->
  robot.whose = (message) -> "@#{message.message.user.name}"

  robot.respond /what data\?$/i, (msg) ->
    msg.send pjson msg.envelope

module.exports = InitBot
