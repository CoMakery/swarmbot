# Description:
#   User / account managemnet
#
# Commands:
#   hubot register btc <btc_address>
#   hubot register email <email>
#   hubot register community <preferred community>

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
    #TODO: would  be nice to send out an outbound email notification that then allows them to setup a BTC wallet
    msg.send "User registered"

  # The following is a way of setting a preferred DCO
  robot.respond /register community (.+)$/i, (msg) ->
    msg.match.shift()
    [community] = msg.match
    activeUser = robot.whose msg
    usersRef = swarmbot.firebase().child('users')
    usersRef.push( slack_username: activeUser, community: community )
    msg.send "Preferred community set"
