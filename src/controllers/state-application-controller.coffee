{ log, p, pjson } = require 'lightsaber'
User = require '../models/user'
Promise = require 'bluebird'
DCO = require '../models/dco'
swarmbot = require '../models/swarmbot'

class ApplicationController
  constructor: (@router, @msg) ->
    @currentUser = @msg.currentUser

  execute: (menuAction) ->
    @currentUser.set 'stateData', menuAction.data if menuAction.data

    if menuAction.command?
      @[menuAction.command]()

    if menuAction.transition?
      if @currentUser[menuAction.transition]
        @currentUser[menuAction.transition]()
        @redirect()
      else
        throw new Error "Requested state transition is undefined! Event '#{menuAction.transition}' from state '#{@currentUser.current}'"

  redirect: ->
    @msg.match = [] # call default action in the next state
    @router.route(@msg)

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
