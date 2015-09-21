{ p, pjson } = require 'lightsaber'
ApplicationController = require './application-controller'
swarmbot = require '../models/swarmbot'
Bounty = require '../models/bounty'
User = require '../models/user'
DCO = require '../models/dco'

class UsersController extends ApplicationController
  register: (@msg) ->
    @currentUser().once 'sync', (user) =>
      slackId = @msg.message.user.id
      realName = @msg.message.user.real_name
      emailAddress = @msg.message.user.email_address
      p user, slackId, realName, emailAddress

      if realName
        user.set "real_name", realName
        @msg.send "registered real name"

      if emailAddress
        user.set "email_address", emailAddress
        @msg.send "registered email address"

      if slackId
        user.set "slack_id", slackId
        @msg.send "registered slack id"

  registerBtc: (@msg, { btcAddress }) ->
    user = @currentUser()
    user.set "btc_address", btcAddress
    @msg.send "BTC address #{btcAddress} registered."

  setCommunity: (@msg, { community }) ->
    user = @currentUser()
    user.set "current_community", community
    @msg.send "Your current community is '#{community}'"

module.exports = UsersController
