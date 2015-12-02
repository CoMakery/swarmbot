{ log, p, pjson } = require 'lightsaber'
User = require '../models/user'
Promise = require 'bluebird'
DCO = require '../models/dco'

class ApplicationController
  currentUser: ->
    @_currentUser ||= new User name: @msg.robot.whose(@msg)

  getDco: ->
    if @community?
      Promise.resolve(DCO.find(@community)).bind(@)
    else
      @currentUser().fetchIfNeeded().bind(@).then (user) ->
        @community = user.get('current_dco')
        if @community?
          DCO.find(@community)
        else
          Promise.reject(Promise.OperationalError("Please either set a community or specify the community in the command."))

  _showError: (error)->
    @msg.send error.message

  _userText: (user)->
    if user?
      info = ""
      info += "real name: " + user.get('real_name')
      info += ", slack username: " + user.get('slack_username')
      info += ", default community: " + user.get('current_dco')
      info += ", receiving address: " + user.get('btc_address')
    else
      "User not found"

module.exports = ApplicationController
