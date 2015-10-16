{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './state-application-controller'
ProposalCollection = require '../collections/proposal-collection'
Proposal = require '../models/proposal'
ShowView = require '../views/proposals/show-view'
IndexView = require '../views/proposals/index-view'
CreateView = require '../views/proposals/create-view'

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
        proposal.upvote @currentUser
      .then =>
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


module.exports = ProposalsStateController
