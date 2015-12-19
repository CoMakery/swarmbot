request = require 'request-promise'
validator = require 'validator'
debug = require('debug')('app')
errorLog = require('debug')('error')
{ json, log, p, pjson, type } = require 'lightsaber'
{ extend, isEmpty } = require 'lodash'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
User = require '../models/user'
Project = require '../models/project'
ZorkHelper = require '../helpers/zork-helper'

class ApplicationStateController
  constructor: (@msg)->
    @currentUser = @msg.currentUser

  sendPm: (textOrAttachments)=>
    App.addFallbackTextIfNeeded textOrAttachments
    App.pmReply @msg, textOrAttachments

  sendInfo:     (text)=> App.pmReply @msg, ZorkHelper::info text
  sendQuestion: (text)=> App.pmReply @msg, ZorkHelper::question text
  sendWarning:  (text)=> App.pmReply @msg, ZorkHelper::warning text

  execute: (menuAction)->
    promise = Promise.resolve()
    if menuAction.command?
      promise = promise.then =>
        @[menuAction.command](menuAction.data)

    if menuAction.transition?
      promise = promise.then =>
        @currentUser.set 'stateData', (menuAction.data or {})
      .then (@currentUser)=>
        transitionMethod = @currentUser[menuAction.transition]
        if type(transitionMethod) is 'function'
          @currentUser[menuAction.transition]()
          debug 'redirecting...'
          @redirect(menuAction.flashMessage)
        else if type(transitionMethod) in ['null', 'undefined']
          errorLog "Requested state transition is undefined! Event '#{menuAction.transition}' from state '#{@currentUser.get('state')}'"
          @reset()

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

  getProject: ->
    @currentUser.fetchIfNeeded().bind(@).then (user)->
      projectId = user.get('currentProject')
      if projectId?
        Project.find projectId
      else
        @reset()

  reset: ->
    errorLog "Resetting to #{User::initialState} from state: #{json @currentUser?.get 'state'}, stateData: #{json @currentUser?.get 'stateData'}"
    @currentUser?.reset()
    .then => @redirect()

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
        Promise.reject(Promise.OperationalError("Sorry, we can't download that, please try a different image..."))
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
