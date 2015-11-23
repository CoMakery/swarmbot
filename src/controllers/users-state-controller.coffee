
{ log, p, pjson } = require 'lightsaber'
{ address } = require 'bitcoinjs-lib'
Promise = require 'bluebird'
ApplicationController = require './application-state-controller'
swarmbot = require '../models/swarmbot'
DCO = require '../models/dco'
DcoCollection = require '../collections/dco-collection'
ShowView = require '../views/users/show-view'
BtcView = require '../views/users/btc-view'
SetDcoView = require '../views/users/set-dco-view'
BalanceView = require '../views/general/balance-view'

class UsersStateController extends ApplicationController

  # TODO:
  # consider switching to just users#edit and users#update controller actions:
  #
  # edit  # read the state and render setBtc or setDco tempalate
  # update # read the state and update the right field from the input


  # choose DCO
  setDco: ->
    DcoCollection.all().then (dcos) =>
      view = new SetDcoView dcos
      @currentUser.set 'menu', view.menu
      view.render()

  # set DCO
  setDcoTo: (params)->
    @currentUser.setDcoTo(params.id).then =>
      @currentUser.exit()
      @redirect "Project set to #{params.name}"

  myAccount: ->
    # show current user data
    @render(new ShowView @currentUser)

  setBtc: ->
    btcAddress = @input
    if btcAddress?
      try
        address.fromBase58Check(btcAddress)
        @currentUser.set "btc_address", btcAddress
        @sendInfo "BTC address #{btcAddress} registered."
        return @execute { transition: 'exit' }
      catch error
        console.error "exception thrown on bitcoin address entry: " + error.message

    @render new BtcView({address: btcAddress}, error)

  balance: ->
    new Promise (resolve, reject) =>
      @msg.http "#{swarmbot.coluExplorerUrl()}/api/getaddressinfo?address=#{@currentUser.get('btc_address')}"
      .get() (error, res, body) =>
        if error
          reject(error)
        else
          data = JSON.parse body
          Promise.map data.assets, (asset) ->
            DCO.findBy 'coluAssetId', asset.assetId
            .then (dco) =>
              asset.name = dco.get('name')
              asset
            .catch =>
              asset
          .then (assets) =>
            resolve @render new BalanceView assets: assets


module.exports = UsersStateController
