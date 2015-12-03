debug = require('debug')('app')
{ log, p, pjson } = require 'lightsaber'
{ map } = require 'lodash'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
ApplicationController = require './application-state-controller'
DCO = require '../models/dco.coffee'
User = require '../models/user'
ProposalCollection = require '../collections/proposal-collection'
DcoCollection = require '../collections/dco-collection'
IndexView = require '../views/dcos/index'
CreateView = require '../views/dcos/create-view'
ShowView = require '../views/dcos/show-view'
CapTableView = require '../views/dcos/cap-table-view'

class DcosStateController extends ApplicationController
  index: ->
    DcoCollection.all()
    .then (@dcos)=>
      @currentUser.balances()
    .then (@userBalances)=>
      debug @userBalances
      @render new IndexView {@dcos, @currentUser, @userBalances}

  show: ->
    @getDco()
    .then (dco)=> dco.fetch()
    .then (dco)=>
      @render new ShowView {dco, @currentUser, userBalance: {}}
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

  capTable: ->
    @getDco()
    .then (dco)=>
      assetId = dco.get('coluAssetId')
      new Promise (resolve, reject)=>
        @msg.http "#{swarmbot.coluExplorerUrl()}/api/getassetinfowithtransactions?assetId=#{assetId}"
        .get() (error, res, body)=>
          if error
            reject error
          else
            data = JSON.parse body
            # names
            Promise.map data.holders, (holder)->
              User.findBy 'btc_address', holder.address
              .then (user)=>
                holder.name = user.get('slack_username')
                holder
              .catch =>
                holder

            .then (holders)=>
              debug holders
              resolve @render new CapTableView {project: dco, capTable: holders}

module.exports = DcosStateController
