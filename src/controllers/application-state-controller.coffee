request = require 'request-promise'
validator = require 'validator'
{ json, log, p, pjson, type } = require 'lightsaber'
{ extend, isEmpty } = require 'lodash'
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

  sendInfo:     (text)=> @sendPm ZorkHelper::info text
  sendQuestion: (text)=> @sendPm ZorkHelper::question text
  sendWarning:  (text)=> @sendPm ZorkHelper::warning text

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
    if view.menu
      @currentUser.set('menu', view.menu)
      .then ->
        view.render()
    else
      Promise.resolve(view.render())

  getProject: ->
    @currentUser.fetchIfNeeded().then (user)->
      projectId = user.get('currentProject')

      unless projectId?
        user.reset()
        .then =>
          Promise.reject(new Promise.OperationalError("Couldn't find current project with name \"#{projectId}\""))

      else
        Project.find(projectId)
        .then (@project)=>
          if @project.exists()
            @project
          else
            user.reset() # this is untestable, we shouldn't be doing this in a callback or we should promiseify this whole method
            .then =>
              Promise.reject(new Promise.OperationalError("Couldn't find current project with name \"#{projectId}\""))

  reset: ->
    errorLog "Resetting to #{User::initialState} from state: #{json @currentUser?.get 'state'}, stateData: #{json @currentUser?.get 'stateData'}"
    @currentUser?.reset()
    .then =>
      @redirect()

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
      Promise.reject(Promise.OperationalError("Sorry, we can't seem to download that image, please try a different image..."))
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

  _showError: (error)=>
    @sendWarning(error.message)

  handleError: (error)=>
    @sendWarning(error.message)
    @reset()

module.exports = ApplicationStateController
