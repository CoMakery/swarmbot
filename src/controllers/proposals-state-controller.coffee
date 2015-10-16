{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './state-application-controller'
ProposalCollection = require '../collections/proposal-collection'
Proposal = require '../models/proposal'
ShowView = require '../views/proposals/show-view'
IndexView = require '../views/proposals/index-view'
CreateView = require '../views/proposals/create-view'
CreateSolutionView = require '../views/solutions/create-view'

class ProposalsStateController extends ApplicationController

  index: ->
    @getDco()
    .then (dco) => dco.fetch()
    .then (dco) =>
      proposals = new ProposalCollection(dco.snapshot.child('proposals'), parent: dco)
      proposals.sortByReputationScore()

      @render(new IndexView(proposals))

  show: (params) ->
    proposalId = params.id ? throw new Error "show requires an id"
    @getDco()
    .then (dco) => Proposal.find proposalId, parent: dco
    .then (proposal) =>
      @render(new ShowView(proposal))

  upvote: (params) ->
    @getDco().then (dco) ->
      Proposal.find(params.proposalId, parent: dco)
      .then (proposal) =>
        unless proposal.exists()
          throw new Error "Could not find the proposal '#{params.proposalId}'. Please verify that it exists."
        attributes = {}
        attributes[@currentUser.get 'id'] = 1
        proposal.firebase().child('votes').update attributes, =>
          @msg.send "Your vote has been recorded.\n" # Not
          @redirect()

  create: ->
    if @input?
      data = @currentUser.get('stateData') ? {}
      if not data.id?
        data.id = @input
      else if not data.description?
        data.description = @input
        @getDco()
        .then (dco) =>
          dco.createProposal data
        .then =>
          @msg.send "Proposal created!"
          @execute transition: 'exit'

    data ?= {}
    @currentUser.set 'stateData', data

    @render(new CreateView(data))

  # TODO: move to solutions controller
  solutionsCreate: (data)->
    if @input?
      if not data.id?
        data.id = @input
      else if not data.link?
        data.link = @input
        @getDco()
        .then (dco) =>
          proposal = Proposal.find data.proposalId, parent: dco
        .then (proposal) =>
        # TODO:
        #   proposal.createSolution data
        # .then (solution) =>
          @msg.send "Your solution has been submitted and will be reviewed!"
          # go back to proposals show
          @currentUser.set 'stateData', id: data.proposalId
          @execute transition: 'exit'

    data ?= {}
    @currentUser.set 'stateData', data

    @render(new CreateSolutionView(data))

module.exports = ProposalsStateController
