{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-controller'
ProposalCollection = require '../collections/proposal-collection'
Proposal = require '../models/proposal'
HomeView = require '../views/proposals/home-view'
ShowView = require '../views/proposals/show-view'
IndexView = require '../views/proposals/index-view'

class ProposalsStateController extends ApplicationController
  stateActions:
    'home': 'home'
    'proposalsIndex': 'index'
    'proposalsShow': 'show'

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
    p 'voting up'

  voteDown: ->
    p 'voting down'

module.exports = ProposalsStateController
