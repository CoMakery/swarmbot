
{ log, p, pjson } = require 'lightsaber'
{ address } = require 'bitcoinjs-lib'
Promise = require 'bluebird'
ApplicationController = require './application-state-controller'
swarmbot = require '../models/swarmbot'
Project = require '../models/project'
ProjectCollection = require '../collections/project-collection'
ShowView = require '../views/users/show-view'
BtcView = require '../views/users/btc-view'
BalanceView = require '../views/users/balance-view'
WelcomeView = require '../views/users/welcome-view'

class UsersStateController extends ApplicationController

  # TODO:
  # consider switching to just users#edit and users#update controller actions:
  #
  # edit  # read the state and render setBtc or setProject template
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
        @currentUser.set "btcAddress", btcAddress
        @sendInfo "BTC address #{btcAddress} registered."
        return @execute { transition: 'exit' }
      catch error
        console.error "exception thrown on bitcoin address entry: " + error.message

    @render new BtcView({address: btcAddress}, error)

module.exports = UsersStateController
