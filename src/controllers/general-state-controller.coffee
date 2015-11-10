{ log, p, pjson } = require 'lightsaber'
Promise = require 'bluebird'
ApplicationController = require './application-state-controller'
ProposalCollection = require '../collections/proposal-collection'
Proposal = require '../models/proposal'
HomeView = require '../views/general/home-view'
MoreCommandsView = require '../views/general/more-commands-view'
CapTableView = require '../views/general/cap-table-view'
AdvancedCommandsView = require '../views/general/advanced-commands-view'

class GeneralStateController extends ApplicationController

  home: ->
    @getDco()
    .then (dco) => dco.fetch()
    .then (dco) =>
      proposals = new ProposalCollection(dco.snapshot.child('proposals'), parent: dco)
      # if proposals.isEmpty()
      #   return @msg.send "There are no proposals to display in #{dco.get('id')}."
      proposals.sortByReputationScore()
      # messages = proposals.map(@_proposalMessage)[0...5]

      @render new HomeView dco, proposals
    .error(@_showError)

  more: -> @render new MoreCommandsView

  capTable: ->
    new Promise (resolve, reject) =>
      @msg.http "https://testnet.explorer.coloredcoins.org/api/getassetinfowithtransactions?assetId=LDTvJRTEXJNAzEuZwGtnZJMhwMipGRfH5QeXJ"
      .get() (error, res, body) =>
        if error
          reject error
        else
          data = JSON.parse body
          capTable = data.holders
          resolve @render new CapTableView {capTable}

  advanced: ->
    @render new AdvancedCommandsView @msg.robot

module.exports = GeneralStateController
