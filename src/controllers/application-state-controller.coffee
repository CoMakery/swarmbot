request = require 'request-promise'
validator = require 'validator'
debug = require('debug')('app')
{ log, p, pjson, type } = require 'lightsaber'
{ extend, isEmpty } = require 'lodash'
User = require '../models/user'
Promise = require 'bluebird'
DCO = require '../models/dco'
swarmbot = require '../models/swarmbot'
ZorkHelper = require '../helpers/zork-helper'

class ApplicationStateController
  constructor: (@msg)->
    @currentUser = @msg.currentUser

  sendPm: (attachment)=> @msg.robot.pmReply @msg, attachment

  sendInfo:     (text)=> @msg.robot.pmReply @msg, ZorkHelper::info text
  sendQuestion: (text)=> @msg.robot.pmReply @msg, ZorkHelper::question text
  sendWarning:  (text)=> @msg.robot.pmReply @msg, ZorkHelper::warning text

  execute: (menuAction)->
    promise = Promise.resolve()
    if menuAction.command?
      promise = promise.then =>
        @[menuAction.command](menuAction.data)

    if menuAction.transition?
      promise = promise.then =>
        @currentUser.set 'stateData', menuAction.data or {}
        transitionMethod = @currentUser[menuAction.transition]
        if type(transitionMethod) is 'function'
          @currentUser[menuAction.transition]()
          debug 'redirecting...'
          @redirect(menuAction.flashMessage)
        else if type(transitionMethod) in ['null', 'undefined']
          throw new Error "Requested state transition is undefined! Event '#{menuAction.transition}' from state '#{@currentUser.current}'"
        else if type(transitionMethod) in ['null', 'undefined']
          throw new Error "Requested state transition '#{json transitionMethod}' is not a function! Event '#{menuAction.transition}' from state '#{@currentUser.current}'"

    if menuAction.teleport?
      promise = promise.then =>
        Promise.all [
          @currentUser.set 'stateData', menuAction.data or {}
          @currentUser.set 'state', menuAction.teleport
        ]
      .then =>
        @redirect()

    promise

  redirect: (flashMessage)->
    @sendInfo flashMessage if flashMessage
    @msg.match = [] # call default action in the next state
    App.route @msg

  render: (view)->
    @currentUser.set 'menu', view.menu if view.menu  # asyncronously saves to DB
    view.render()                                    # don't wait for it, just render

  getDco: ->
    @currentUser.fetchIfNeeded().bind(@).then (user)->
      dcoId = user.get('current_dco')
      if dcoId?
        DCO.find dcoId
      else
        Promise.reject(Promise.OperationalError("Please specify the project in the command."))

  parseImageUrl: (ignore='n')->
    if @input.trim().toLowerCase() is ignore
      Promise.resolve()
    else
      @isValidSlackImage(@input).then => @input

  isValidSlackImage: (uri)->
    if not validator.isURL(uri, require_protocol: true)
      return Promise.reject(Promise.OperationalError("Sorry, that is not a valid URL."))

    @sendInfo "Fetching image..."
    request.head
      uri: uri
      resolveWithFullResponse: true
    .then (response)=> response # needed to make promise a bluebird promise...
    .error (error)=>
      debug error.message
      Promise.reject(Promise.OperationalError("Sorry, that address doesn't seem to exist."))
    .then (response)=>
      if not response.headers['content-type']?.startsWith 'image/'
        Promise.reject(Promise.OperationalError("Sorry, that doesn't seem to be an image..."))
      else if response.headers['content-length'] >= App.MAX_SLACK_IMAGE_SIZE
        Promise.reject(Promise.OperationalError("Sorry, that image is too large. Try one of less than half a megabyte..."))

  _coloredCoinTxUrl: (txId)->
    url = ["http://coloredcoins.org/explorer"]
    url.push 'testnet' if process.env.COLU_NETWORK is 'testnet'
    url.push 'tx', txId
    url.join('/')

  _showError: (error)->
    @sendWarning error.message

module.exports = ApplicationStateController
