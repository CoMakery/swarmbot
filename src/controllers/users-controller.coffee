{ p, pjson } = require 'lightsaber'
ApplicationController = require './application-controller'
swarmbot = require '../models/swarmbot'
User = require '../models/user'
DCO = require '../models/dco'

class UsersController extends ApplicationController
  register: (@msg) ->
    # p "currentUser", @currentUser()
    @currentUser().fetch().then (user) =>

      slackUsername = @msg.message.user.name
      slackId = @msg.message.user.id
      realName = @msg.message.user.real_name
      emailAddress = @msg.message.user.email_address
      # p user, slackId, realName, emailAddress

       # quickfix, set to silent register, now that it is automated

      if slackUsername
        user.set "slack_username", slackUsername
        user.set "last_active_on_slack", Date.now()

      if  process.env.HUBOT_DEFAULT_COMMUNITY && user.getDCO == null
        user.set "current_dco", process.env.HUBOT_DEFAULT_COMMUNITY
        # @msg.send "registered Slack username"

      if realName
        user.set "real_name", realName
        # @msg.send "registered real name"

      if emailAddress
        user.set "email_address", emailAddress
        # @msg.send "registered email address"

      if slackId
        user.set "slack_id", slackId
        # @msg.send "registered slack id"

  registerBtc: (@msg, { btcAddress }) ->
    user = @currentUser()
    user.set "btc_address", btcAddress
    @msg.send "BTC address #{btcAddress} registered."

  setCommunity: (@msg, { community }) ->
    user = @currentUser()
    user.setDco community
    @msg.send "Your current community is now '#{community}'."

  unsetCommunity: (@msg) ->
    user = @currentUser()
    user.setDco null
    @msg.send "Your current community has been unset."

  getInfo: (@msg, { slackUsername }) ->
    userPromise = if slackUsername != 'me'
      User.findBySlackUsername(slackUsername)
    else
      @currentUser().fetch()

    userPromise.then (user) =>
      info = @_userText(user)
      @msg.send info

module.exports = UsersController
