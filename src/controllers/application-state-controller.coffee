debug = require('debug')('app')
{ log, p, pjson, type } = require 'lightsaber'
{ extend, isEmpty } = require 'lodash'
User = require '../models/user'
Promise = require 'bluebird'
DCO = require '../models/dco'
swarmbot = require '../models/swarmbot'
ZorkHelper = require '../helpers/zork-helper'

class ApplicationStateController
  constructor: (@msg) ->
    @currentUser = @msg.currentUser

  sendInfo:     (text) => @msg.robot.pmReply @msg, ZorkHelper::info text
  sendQuestion: (text) => @msg.robot.pmReply @msg, ZorkHelper::question text
  sendWarning:  (text) => @msg.robot.pmReply @msg, ZorkHelper::warning text

  execute: (menuAction) ->
    promise = Promise.resolve()
    if menuAction.command?
      promise = promise.then =>
        @[menuAction.command](menuAction.data)

    if menuAction.transition?
      promise = promise.then =>
        @currentUser.set 'stateData', menuAction.data or {}
        if @currentUser[menuAction.transition]
          @currentUser[menuAction.transition]()
          debug 'redirecting...'
          @redirect()
        else
          throw new Error "Requested state transition is undefined! Event '#{menuAction.transition}' from state '#{@currentUser.current}'"

    promise

  redirect: (flashMessage) ->
    @sendInfo flashMessage if flashMessage
    @msg.match = [] # call default action in the next state
    App.route @msg

  render: (view) ->
    @currentUser.set 'menu', view.menu if view.menu
    view.render()

  getDco: ->
    @currentUser.fetchIfNeeded().bind(@).then (user) ->
      dcoId = user.get('current_dco')
      dcoId ?= swarmbot.feedbackDcokey
      if dcoId?
        DCO.find dcoId
      else
        Promise.reject(Promise.OperationalError("Please specify the project in the command."))

  _showError: (error)->
    @sendWarning error.message

module.exports = ApplicationStateController
