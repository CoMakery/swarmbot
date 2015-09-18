{ p } = require 'lightsaber'
swarmbot = require '../models/swarmbot'
Bounty = require '../models/bounty'
User = require '../models/user'
DCO = require '../models/dco'

class UsersController
  register: (msg) ->
    activeUser = msg.robot.whose msg
    user = User.find activeUser
    slackId = msg.message.user.id
    realName = msg.message.user.real_name
    emailAddress = msg.message.user.email_address
    p activeUser, user, slackId, realName, emailAddress

    if realName
      user.register "real_name", realName
      msg.send "registered real name"

    if emailAddress
      user.register "email_address", emailAddress
      msg.send "registered email address"

    if slackId
      user.register "slack_id", slackId
      msg.send "registered slack id"

  registerBtc: (msg, { btcAddress }) ->
    activeUser = msg.robot.whose msg
    user = User.find activeUser
    user.register "btc_address", btcAddress
    msg.send "BTC address #{btcAddress} registered."

  setCommunity: (msg, { community }) ->
    activeUser = msg.robot.whose msg
    user = User.find activeUser
    user.register "current_community", community
    msg.send "Current community set to '#{community}'"

module.exports = UsersController
