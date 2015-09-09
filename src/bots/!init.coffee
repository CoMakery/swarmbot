# Commands:
#

InitBot = (robot) ->
  robot.whose = (message) -> "@#{message.message.user.name}"

module.exports = InitBot
