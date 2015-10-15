{ log, p, pjson } = require 'lightsaber'
User = require '../models/user'
Promise = require 'bluebird'
DCO = require '../models/dco'
swarmbot = require '../models/swarmbot'

class ApplicationController
  constructor: (@router, @msg) ->
    @currentUser = @msg.currentUser

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

  execute: (action) ->
    @currentUser.set 'stateData', action.data if action.data

    if action.command?
      @[action.command]()

    if action.transition?
      unless @currentUser[action.transition]
        throw new Error "Requested state transition is undefined! Event '#{action.transition}' from state '#{@currentUser.current}'"
      @currentUser[action.transition]()
      @redirect()

  redirect: ->
    @msg.match = [] # call default action in the next state
    @router.route(@msg)

  stateAction: ->
    userState = @currentUser.current
    controllerMethodName = @stateActions[userState]
    controllerMethod = @[controllerMethodName].bind @
    stateData = @currentUser.get 'stateData'
    controllerMethod stateData

  render: (view)->
    @currentUser.set 'menu', view.menu
    @msg.send view.render()

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

module.exports = ApplicationController
