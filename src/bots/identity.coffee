# Description:
#   User / account managemnet
#
# Commands:
#   hubot register me
#   hubot register btc <btc_address>
#   hubot set community <preferred community>

# Not in use:
#   hubot register email <email>

swarmbot = require '../models/swarmbot'
Bounty = require '../models/bounty'
User = require '../models/user'
DCO = require '../models/dco'
{ values } = require 'lodash'

module.exports = (robot) ->

 # Not sure, this may work in slack, not sure about
 #  robot.respond /register?.*/i, (msg) ->
 #    robot.reply 'some msg'?

  robot.respond /register me$/i, (msg) ->

      activeUser = robot.whose msg
      user = User.find activeUser
      slackId = msg.message.user.id
      realName = msg.message.user.real_name
      emailAddress = msg.message.user.email_address
      if realName
        user.register "real_name", realName
        msg.send "registered real name"

      if emailAddress
        user.register "email_address", emailAddress
        msg.send "registered email address"

      if slackId
        user.register "slack_id", slackId
        msg.send "registered slack id"

  robot.respond /register btc (.+)$/i, (msg) ->
    msg.match.shift()
    [btcAddress] = msg.match
    activeUser = robot.whose msg
    user = User.find activeUser
    user.register "btc_address", btcAddress
    msg.send "User registered"

  # robot.respond /register email (.+)$/i, (msg) ->
  #   msg.match.shift()
  #   [emailAddress] = msg.match
  #   activeUser = robot.whose msg
  #   user = User.find activeUser
  #   user.register "email_address", emailAddress

    #TODO: would  be nice to send out an outbound email notification that then allows them to setup a BTC wallet
    # something like the Mandril usage we have in the Swarm API
    # https://swarm-rome.herokuapp.com/messages/send-template

    # msg.send "Email registered"

  # The following is a way of setting a preferred DCO
  robot.respond /set community (.+)$/i, (msg) ->
    msg.match.shift()
    [community] = msg.match
    activeUser = robot.whose msg
    user = User.find activeUser
    user.register "preferred_community", community
    msg.send "Preferred community set"
