{ log, p, pjson } = require 'lightsaber'
debug = require('debug')('app')
request = require 'request-promise'
Promise = require 'bluebird'
ApplicationController = require './application-state-controller'
AwardCollection = require '../collections/award-collection'
Award = require '../models/award'
ShowView = require '../views/proposals/show-view'
CreateView = require '../views/proposals/create-view'
EditView = require '../views/proposals/edit-view'
ZorkView = require '../views/zork-view'

class ProposalsStateController extends ApplicationController

  show: (data)->
    proposalId = data.proposalId ? throw new Error "show requires an id"
    @getDco()
    .then (dco)=> Award.find(proposalId, parent: dco)
    .then (proposal)=>
      canSetBounty = (proposal.parent.get('project_owner') == @currentUser.key())
      @render(new ShowView(proposal, { canSetBounty }))

  upvote: (data)->
    @getDco().then (dco)=>
      Award.find(data.proposalId, parent: dco)
    .then (proposal)=>
      unless proposal.exists()
        throw new Error "Could not find the task '#{data.proposalId}'. Please verify that it exists."
      proposal.upvote @currentUser
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
      @getDco()
      .then (dco)=> dco.makeProposal name: @input  # throws op error if already exists
      .then => data.name = @input
    else if not data.suggestedAmount?
      data.suggestedAmount = @input.trim()
      promise = @getDco()
        .then (dco)=> dco.createProposal data
        .then (@proposal)=> # @proposal = proposal

    promise
    .then => @currentUser.set 'stateData', data
    .then =>
      if @proposal
        @execute transition: 'exit', flashMessage: "Award created!"
      else
        @render new CreateView {data, @errorMessage}

  edit: (data)->
    if @input?
      if not data.bounty?
        if @input.match /^\d+$/
          data.bounty = @input
          return @getDco()
          .then (dco)-> Award.find data.proposalId, parent: dco
          .then (proposal)-> proposal.set 'amount', data.bounty
          .then =>
            @sendInfo "Bounty amount set to #{data.bounty}"
            @execute transition: 'exit', data: {proposalId: data.proposalId}
        else
          @sendWarning "For a bounty amount, please enter only numbers"

    data ?= {}
    @currentUser.set 'stateData', data
    @render new EditView data

module.exports = ProposalsStateController
