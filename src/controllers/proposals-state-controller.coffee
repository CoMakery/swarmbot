{ log, p, pjson } = require 'lightsaber'
debug = require('debug')('app')
request = require 'request-promise'
validator = require 'validator'
Promise = require 'bluebird'
ApplicationController = require './application-state-controller'
ProposalCollection = require '../collections/proposal-collection'
Proposal = require '../models/proposal'
ShowView = require '../views/proposals/show-view'
IndexView = require '../views/proposals/index-view'
CreateView = require '../views/proposals/create-view'
EditView = require '../views/proposals/edit-view'
ZorkView = require '../views/zork-view'

class ProposalsStateController extends ApplicationController

  index: ->
    @getDco()
    .then (dco) => dco.fetch()
    .then (dco) =>
      proposals = new ProposalCollection(dco.snapshot.child('proposals'), parent: dco)
      proposals.sortByReputationScore()

      @render(new IndexView(proposals))

  show: (data) ->
    proposalId = data.proposalId ? throw new Error "show requires an id"
    @getDco()
    .then (dco) => Proposal.find(proposalId, parent: dco)
    .then (proposal) =>
      canSetBounty = (proposal.parent.get('project_owner') == @currentUser.key())
      @render(new ShowView(proposal, { canSetBounty }))

  upvote: (data) ->
    @getDco().then (dco) =>
      Proposal.find(data.proposalId, parent: dco)
    .then (proposal) =>
      unless proposal.exists()
        throw new Error "Could not find the task '#{data.proposalId}'. Please verify that it exists."
      proposal.upvote @currentUser
    .then =>
      @redirect "Your vote has been recorded."

  isValidSlackImage: (uri) ->
    if not validator.isURL(uri, require_protocol: true)
      return Promise.reject(Promise.OperationalError("Sorry, that is not a valid URL."))

    @sendInfo "Fetching image..."
    request.head
      uri: uri
      resolveWithFullResponse: true
    .then (response) => response # needed to make promise a bluebird promise...
    .error (error) =>
      debug error.message
      Promise.reject(Promise.OperationalError("Sorry, that address doesn't seem to exist."))
    .then (response) =>
      if not response.headers['content-type']?.startsWith 'image/'
        Promise.reject(Promise.OperationalError("Sorry, that doesn't seem to be an image..."))
      else if response.headers['content-length'] >= App.MAX_SLACK_IMAGE_SIZE
        Promise.reject(Promise.OperationalError("Sorry, that image is too large. Try one of less than half a megabyte..."))

  create: (data) ->
    data ?= {}
    result = \
      if @input?
        if not data.name?
          @getDco()
          .then (dco) => dco.makeProposal name: @input  # throws op error if already exists
          .then => data.name = @input
        else if not data.description?
          data.description = @input
        else if not data.imageUrl?
          if @input in ['n', 'N']
            Promise.resolve(done: true)
          else
            @isValidSlackImage(@input).then =>
              data.imageUrl = @input
              done: true

    result = Promise.resolve(done: false) unless result?.then?

    result
    .error (opError) =>
      @errorMessage = opError.message
    .then ({done})=>
      if done
        @getDco()
        .then (dco) => dco.createProposal data
        .then => @sendInfo "Task created!"
        .then => @execute transition: 'exit'
        .error (opError) =>
          @render new CreateView {data, errorMessage: opError.message}
      else
        @currentUser.set 'stateData', data
        .then =>
          @render new CreateView {data, @errorMessage}

  edit: (data) ->
    if @input?
      if not data.bounty?
        if @input.match /^\d+$/
          data.bounty = @input
          return @getDco()
          .then (dco) -> Proposal.find data.proposalId, parent: dco
          .then (proposal) -> proposal.set 'amount', data.bounty
          .then =>
            @sendInfo "Bounty amount set to #{data.bounty}"
            @execute transition: 'exit', data: {proposalId: data.proposalId}
        else
          @sendWarning "For a bounty amount, please enter only numbers"

    data ?= {}
    @currentUser.set 'stateData', data
    @render new EditView data

module.exports = ProposalsStateController
