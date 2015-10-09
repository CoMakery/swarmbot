{ log, p, pjson } = require 'lightsaber'
User = require '../models/user'
Promise = require 'bluebird'
DCO = require '../models/dco'

class ApplicationController
  constructor: (@router, @msg) ->
    @currentUser = @msg.currentUser

  getDco: ->
    @currentUser.fetchIfNeeded().bind(@).then (user) ->
      dcoId = user.get('current_dco')
      if dcoId?
        DCO.find dcoId
      else
        Promise.reject(Promise.OperationalError("Please specify the community in the command."))

  _showError: (error)->
    @msg.send error.message

  # _userText: (user)->
  #   if user?
  #     info = ""
  #     info += "real name: " + user.get('real_name')
  #     info += ", slack username: " + user.get('slack_username')
  #     info += ", default community: " + user.get('current_dco')
  #     info += ", receiving address: " + user.get('btc_address')
  #   else
  #     "User not found"

module.exports = ApplicationController
