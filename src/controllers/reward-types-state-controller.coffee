{ log, p, pjson } = require 'lightsaber'
debug = require('debug')('app')
request = require 'request-promise'
Promise = require 'bluebird'
ApplicationController = require './application-state-controller'
RewardTypeCollection = require '../collections/reward-type-collection'
RewardType = require '../models/reward-type'
CreateView = require '../views/reward-types/create-view'
EditView = require '../views/reward-types/edit-view'
ZorkView = require '../views/zork-view'

class RewardTypesStateController extends ApplicationController

  upvote: (data)->
    @getProject().then (project)=>
      RewardType.find(data.rewardTypeId, parent: project)
    .then (rewardType)=>
      unless rewardType.exists()
        throw new Error "Could not find the task '#{data.rewardTypeId}'. Please verify that it exists."
      rewardType.upvote @currentUser
    .then =>
      @redirect "Your vote has been recorded."

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

  create: (data)->
    data ?= {}
    promise = if not @input?
      # fall through to render
      Promise.resolve()
    else if not data.name?
      @getProject()
      .then (project)=> project.makeRewardType name: @input  # throws op error if already exists
      .then => data.name = @input
    else if not data.suggestedAmount?
      data.suggestedAmount = @input.trim()
      promise = @getProject()
        .then (project)=> project.createRewardType data
        .then (@rewardType)=>

    promise
    .then => @currentUser.set 'stateData', data
    .then =>
      if @rewardType
        @execute transition: 'exit', flashMessage: "Award created!"
      else
        @render new CreateView {data, @errorMessage}

  edit: (data)->
    if @input?
      if not data.bounty?
        if @input.match /^\d+$/
          data.bounty = @input
          return @getProject()
          .then (project)-> RewardType.find data.rewardTypeId, parent: project
          .then (rewardType)-> rewardType.set 'amount', data.bounty
          .then =>
            @sendInfo "Bounty amount set to #{data.bounty}"
            @execute transition: 'exit', data: {rewardTypeId: data.rewardTypeId}
        else
          @sendWarning "For a bounty amount, please enter only numbers"

    data ?= {}
    @currentUser.set 'stateData', data
    @render new EditView data

module.exports = RewardTypesStateController
