{ p, pjson } = require 'lightsaber'
{ address } = require 'bitcoinjs-lib'
ApplicationController = require './application-controller'
swarmbot = require '../models/swarmbot'
User = require '../models/user'
Project = require '../models/project'

class UsersController extends ApplicationController
  register: (@msg)->
    # p "currentUser", @currentUser()
    @currentUser().fetch().then (user)=>

      slackUsername = @msg.message.user.name
      slackId = @msg.message.user.id
      realName = @msg.message.user.real_name
      emailAddress = @msg.message.user.email_address
      # p user, slackId, realName, emailAddress, slackUsername

      # quickfix, set to silent register, now that it is automated

      if slackUsername && !user.get('slack_username')
        user.set "account_created", Date.now()
        user.set "slack_username", slackUsername

      if slackUsername
        user.set "last_active_on_slack", Date.now()


      if process.env.HUBOT_DEFAULT_COMMUNITY && !user.get('current_project')
        user.set "current_project", process.env.HUBOT_DEFAULT_COMMUNITY
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

  getInfo: (@msg, { slackUsername })->
    userPromise = if slackUsername == 'me'
      @currentUser().fetch()
    else
      User.findBySlackUsername(slackUsername)

    userPromise.then (user)=>
      info = @_userText(user)
      @msg.send info
    .error (error)=>
      @msg.send error

module.exports = UsersController
