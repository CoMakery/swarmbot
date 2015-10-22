{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './state-application-controller'
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
        @redirect("Your vote has been recorded.\n")

  create: ->
    if @input?
      data = @currentUser.get('stateData') ? {}
      if not data.id?
        data.id = @input
      else if not data.description?
        data.description = @input
        return @getDco()
        .then (dco) => dco.createProposal data
        .then => @msg.send "Proposal created!\n\n"
        .then => @execute transition: 'exit'
    data ?= {}
    @currentUser.set 'stateData', data
    @render new CreateView data

  edit: (params)->
    amount = @input
    if amount?
      # validate that it is a number
      @getDco()
      .then (dco) ->
        Proposal.find params.proposalId, parent: dco
      .then (proposal) ->
        proposal.set 'amount', amount
      .then ->
        @msg.send "Bounty amount set to #{amount}"

      @render new EditView params

module.exports = ProposalsStateController
