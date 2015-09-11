# Description:
#   User / account managemnet
#
# Commands:
#   hubot register btc <btc_address>
#   hubot register email <email>

swarmbot = require '../models/swarmbot'
Bounty = require '../models/bounty'
DCO = require '../models/dco'
{ values } = require 'lodash'

module.exports = (robot) ->

 # Not sure, this may work in slack, not sure about
 #  robot.respond /register?.*/i, (msg) ->
 #    robot.reply 'some msg'?

  robot.respond /register btc (.+)$/i, (msg) ->
    msg.match.shift()
    [btcAddress] = msg.match
    activeUser = robot.whose msg
    usersRef = swarmbot.firebase().child('users')
    #TODO: not sure this should be a push
    usersRef.push( slack_username: activeUser, btc_address: btcAddress )
    msg.send "User registered"

  robot.respond /register email (.+)$/i, (msg) ->
    msg.match.shift()
    [emailAddress] = msg.match
    activeUser = robot.whose msg
    usersRef = swarmbot.firebase().child('users')
    usersRef.push( slack_username: activeUser, emailAddress: emailAddress )
    #TODO: would be nice to send out an outbound email notification
    msg.send "User registered"
