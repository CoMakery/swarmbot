
{ log, p, pjson } = require 'lightsaber'
{ address } = require 'bitcoinjs-lib'
Promise = require 'bluebird'
ApplicationController = require './application-state-controller'
swarmbot = require '../models/swarmbot'
DCO = require '../models/dco'
DcoCollection = require '../collections/dco-collection'
ShowView = require '../views/users/show-view'
BtcView = require '../views/users/btc-view'
BalanceView = require '../views/general/balance-view'
WelcomeView = require '../views/general/welcome-view'

class UsersStateController extends ApplicationController

  # TODO:
  # consider switching to just users#edit and users#update controller actions:
  #
  # edit  # read the state and render setBtc or setDco tempalate
  # update # read the state and update the right field from the input


  welcome: ->
    view = new WelcomeView {@currentUser}
    view.render()

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

module.exports = UsersStateController
