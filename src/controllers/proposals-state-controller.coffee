{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-state-controller'
ProposalCollection = require '../collections/proposal-collection'
Proposal = require '../models/proposal'
ShowView = require '../views/proposals/show-view'
IndexView = require '../views/proposals/index-view'
CreateView = require '../views/proposals/create-view'
EditView = require '../views/proposals/edit-view'

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
    promise = @getDco()
    .then (dco) => Proposal.find(proposalId, parent: dco)
    .then (proposal) =>
      canSetBounty = (proposal.parent.get('project_owner') == @currentUser.get('id'))
      @render(new ShowView(proposal, { canSetBounty }))

  upvote: (params) ->
    @getDco().then (dco) ->
      Proposal.find(params.proposalId, parent: dco)
      .then (proposal) =>
        unless proposal.exists()
          throw new Error "Could not find the proposal '#{params.proposalId}'. Please verify that it exists."
        proposal.upvote @currentUser
      .then =>
        @redirect "Your vote has been recorded."

  create: ->
    if @input?
      data = @currentUser.get('stateData') ? {}
      if not data.id?
        data.id = @input
      else if not data.description?
        data.description = @input
        return @getDco()
        .then (dco) => dco.createProposal data
        .then => @msg.send "Proposal created!\n"
        .then => @execute transition: 'exit'
    data ?= {}
    @currentUser.set 'stateData', data
    @render new CreateView data

  edit: (params) ->
    if @input?
      if not params.bounty?
        if @input.match /^\d+$/
          params.bounty = @input
          return @getDco()
          .then (dco) -> Proposal.find params.proposalId, parent: dco
          .then (proposal) -> proposal.set 'amount', params.bounty
          .then =>
            @msg.send "Bounty amount set to #{params.bounty}\n"
            @execute transition: 'exit', data: { id: params.proposalId }
        else
          @msg.send "For a bounty amount, please enter only numbers\n"

    params ?= {}
    @currentUser.set 'stateData', params
    @render new EditView params

module.exports = ProposalsStateController
