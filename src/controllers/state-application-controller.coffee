debug = require('debug')('app')
{ log, p, pjson } = require 'lightsaber'
User = require '../models/user'
Promise = require 'bluebird'
DCO = require '../models/dco'
swarmbot = require '../models/swarmbot'

class ApplicationController
  constructor: (@msg) ->
    @currentUser = @msg.currentUser

  execute: (menuAction) ->
    promise = Promise.resolve()
    if menuAction.command?
      promise = promise.then =>
        @[menuAction.command](menuAction.data)

    if menuAction.transition?
      promise = promise.then =>
        @currentUser.set 'stateData', menuAction.data if menuAction.data
        if @currentUser[menuAction.transition]
          @currentUser[menuAction.transition]()
          debug 'redirecting...'
          @redirect()
        else
          throw new Error "Requested state transition is undefined! Event '#{menuAction.transition}' from state '#{@currentUser.current}'"

    promise

  redirect: (flashMessage)->
    @msg.send flashMessage if flashMessage?
    @msg.match = [] # call default action in the next state
    App.route(@msg)

  render: (view) ->
    @currentUser.set 'menu', view.menu
    view.render()

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
