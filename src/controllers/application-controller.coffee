{ log, p, pjson } = require 'lightsaber'
User = require '../models/user'
Promise = require 'bluebird'
DCO = require '../models/dco'
swarmbot = require '../models/swarmbot'

class ApplicationController
  constructor: (@router, @msg) ->
    @currentUser = @msg.currentUser

  redirect: ->
    @msg.match = [] # call default action in the next state
    @router.route(@msg)

  execute: (action) ->
    @currentUser.set 'stateData', action.data if action.data

    if action.command?
      @[action.command]()

    if action.transition?
      @currentUser[action.transition]()
      @redirect()

  # ENTRY POINT
  process: ->
    @input = @msg.match[1]
    lastMenuItems = @currentUser.get('menu')
    action = lastMenuItems?[@input?.toLowerCase()]
    if action?
      # specific action of entered command
      @execute(action)
    else if @stateActions[@currentUser.current]?
      # default action of this state
      @stateAction()
    else
      throw new Error("Action for state '#{@currentUser.current}' not defined.")

  stateAction: ->
    @[ @stateActions[@currentUser.current] ](@currentUser.get('stateData'))

  getDco: ->
    @currentUser.fetchIfNeeded().bind(@).then (user) ->
      dcoId = user.get('current_dco')
      dcoId ?= swarmbot.feedbackDcokey
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
