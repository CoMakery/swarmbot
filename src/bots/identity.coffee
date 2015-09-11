# Description:
#   User / account managemnet
#
# Commands:
#   hubot register <btc_address>

swarmbot = require '../models/swarmbot'
Bounty = require '../models/bounty'
DCO = require '../models/dco'
{ values } = require 'lodash'

module.exports = (robot) ->

  # unless Config.adminList()
  #   robot.logger.warning 'HUBOT_TEAM_ADMIN environment variable not set'

 # Not sure, this may work in slack, not sure about
 #  robot.respond /register?.*/i, (msg) ->
 #    robot.reply 'some msg'?

  robot.respond /register (.+)$/i, (msg) ->
    msg.match.shift()
    [btcAddress] = msg.match
    activeUser = robot.whose msg
    usersRef = swarmbot.firebase().child('users')
    usersRef.push( slack_username: activeUser, btc_address: btcAddress )
    msg.send "User registered"
