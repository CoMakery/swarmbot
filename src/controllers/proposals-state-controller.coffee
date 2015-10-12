{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-controller'
ProposalCollection = require '../collections/proposal-collection'
Proposal = require '../models/proposal'
HomeView = require '../views/proposals/home-view'
ShowView = require '../views/proposals/show-view'
IndexView = require '../views/proposals/index-view'
CreateView = require '../views/proposals/create-view'

class ProposalsStateController extends ApplicationController
  stateActions:
    'home': 'home'
    'proposalsIndex': 'index'
    'proposalsShow': 'show'
    'proposalsCreate': 'create'

  home: ->
    @getDco()
    .then (dco) => dco.fetch()
    .then (dco) =>
      proposals = new ProposalCollection(dco.snapshot.child('proposals'), parent: dco)
      # if proposals.isEmpty()
      #   return @msg.send "There are no proposals to display in #{dco.get('id')}."
      proposals.sortByReputationScore()
      # messages = proposals.map(@_proposalMessage)[0...5]

      view = new HomeView(proposals)
      @currentUser.set 'menu', view.menu
      @msg.send view.render()

    .error(@_showError)

  index: ->
    @getDco()
    .then (dco) => dco.fetch()
    .then (dco) =>
      proposals = new ProposalCollection(dco.snapshot.child('proposals'), parent: dco)
      proposals.sortByReputationScore()

      view = new IndexView(proposals)
      @currentUser.set 'menu', view.menu
      @msg.send view.render()

  show: (params) ->
    proposalId = params.id ? throw new Error "show requires an id"
    @getDco()
    .then (dco) => Proposal.find proposalId, parent: dco
    .then (proposal) =>
      # @msg.send @_proposalMessage proposal
      view = new ShowView(proposal)
      @currentUser.set('menu', view.menu)
      @msg.send view.render()

  voteUp: ->
    # TODO: record the vote
    @msg.send 'Your vote has been recorded.' # Not
    @stateAction()

  voteDown: ->
    # TODO: record the vote
    @msg.send 'Your vote has been recorded.' # Not
    @stateAction()

  # {
  #   id: 'a proposal'
  #   description: 'this is a proposal'
  # }
  create: ->
    if @input?
      data = @currentUser.get('stateData') ? {}
      if not data.id?
        data.id = @input
      else if not data.description?
        description = @input
        data.description = description
        @getDco()
        .then (@dco) =>
          @dco.createProposal data
        .then (proposal) =>
          @msg.send "Proposal created!"

    data ?= {}
    @currentUser.set 'stateData', data

    # view here. create menu.
    view = new CreateView(data)
    @currentUser.set('menu', view.menu)

    @msg.send view.render()



    # else
    #   p "We are creating this proposal!", @currentUser.get('stateData')
    #   # create the proposal

module.exports = ProposalsStateController
