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
        throw new Error "Could not find the proposal '#{data.proposalId}'. Please verify that it exists."
      proposal.upvote @currentUser
    .then =>
      @redirect "Your vote has been recorded."

  create: (data) ->
    data ?= {}
    if @input?
      if not data.name?
        data.name = @input
      else if not data.description?
        data.description = @input
      else if not data.imageUrl?
        data.imageUrl = @input
        return @getDco()
        .then (dco) => dco.createProposal data
        .then => @msg.send "Proposal created!\n"
        .then => @execute transition: 'exit'
    @currentUser.set 'stateData', data
    .then => @render new CreateView data

  edit: (data) ->
    if @input?
      if not data.bounty?
        if @input.match /^\d+$/
          data.bounty = @input
          return @getDco()
          .then (dco) -> Proposal.find data.proposalId, parent: dco
          .then (proposal) -> proposal.set 'amount', data.bounty
          .then =>
            @msg.send "Bounty amount set to #{data.bounty}\n"
            @execute transition: 'exit'
        else
          @msg.send "For a bounty amount, please enter only numbers\n"

    data ?= {}
    @currentUser.set 'stateData', data
    @render new EditView data

module.exports = ProposalsStateController
