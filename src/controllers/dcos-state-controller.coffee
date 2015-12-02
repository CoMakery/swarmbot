debug = require('debug')('app')
{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-state-controller'
DCO = require '../models/dco.coffee'
ProposalCollection = require '../collections/proposal-collection'
DcoCollection = require '../collections/dco-collection'
IndexView = require '../views/dcos/index'
CreateView = require '../views/dcos/create-view'
ShowView = require '../views/dcos/show-view'

class DcosStateController extends ApplicationController
  index: ->
    DcoCollection.all()
    .then (@dcos)=>
      @currentUser.balances()
    .then (@userBalances)=>
      debug @userBalances
      @render new IndexView {@dcos, @userBalances}

  show: ->
    @getDco()
    .then (dco)=> dco.fetch()
    .then (dco)=>
      proposals = new ProposalCollection(dco.snapshot.child('proposals'), parent: dco)
      proposals.sortBy 'totalVotes'

      @render new ShowView dco, proposals
    .error(@_showError)

  # set DCO
  setDcoTo: (data)->
    @currentUser.setDcoTo(data.id).then =>
      @currentUser.exit()
      @redirect()

  create: (data={})->
    if @input
      if not data.name
        data.name = @input
      else if not data.description
        data.description = @input
        return @saveDco data

    @currentUser.set 'stateData', data
    .then =>
      @render new CreateView data

  saveDco: (data)->
    new DCO
      name: data.name
      project_statement: data.description
      project_owner: @currentUser.key()
    .save()
    .then (dco)=>
      dco.issueAsset amount: DCO::INITIAL_PROJECT_COINS
      @sendInfo "Project created"
      @currentUser.set 'current_dco', dco.key()
    .then =>
      @execute transition: 'showDco'

module.exports = DcosStateController
