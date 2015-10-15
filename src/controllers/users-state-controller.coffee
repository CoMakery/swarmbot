
{ log, p, pjson } = require 'lightsaber'
{ address } = require 'bitcoinjs-lib'
ApplicationController = require './state-application-controller'
DcoCollection = require '../collections/dco-collection'
ShowView = require '../views/users/show-view'
BtcView = require '../views/users/btc-view'

class UsersStateController extends ApplicationController

  # map of state name -> controller action
  stateActions:
    myAccount: 'myAccount'
    setBtc: 'setBtc'

  myAccount: ->
    # show current user data
    @render(new ShowView @currentUser)

  setBtc: ->
    btcAddress = @input
    if btcAddress?
      try
        address.fromBase58Check(btcAddress)
        @currentUser.set "btc_address", btcAddress
        @msg.send "BTC address #{btcAddress} registered."
        return @execute { transition: 'exit' }
      catch error
        p error.message

    @render new BtcView({address: btcAddress}, error)

module.exports = UsersStateController
