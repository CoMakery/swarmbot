# Commands:
#

Firebase = require 'firebase'
Colu = require 'colu'
swarmbot = require '../models/swarmbot'

swarmbot.configure()

InitBot = (robot) ->
  robot.whose = (message) -> "@#{message.message.user.name}"

module.exports = InitBot
