{ log, p, pjson } = require 'lightsaber'
User = require '../models/user'
Promise = require 'bluebird'
Project = require '../models/project'

class ApplicationController
  currentUser: ->
    @_currentUser ||= new User name: @msg.robot.whose(@msg)

  getProject: ->
    if @community?
      Promise.resolve(Project.find(@community)).bind(@)
    else
      @currentUser().fetchIfNeeded().bind(@).then (user)->
        @community = user.get('current_project')
        if @community?
          Project.find(@community)
        else
          Promise.reject(Promise.OperationalError("Please either set a community or specify the community in the command."))

  _showError: (error)->
    @msg.send error.message

  _userText: (user)->
    if user?
      info = ""
      info += "real name: " + user.get('real_name')
      info += ", slack username: " + user.get('slack_username')
      info += ", default community: " + user.get('current_project')
      info += ", receiving address: " + user.get('btc_address')
    else
      "User not found"

module.exports = ApplicationController
