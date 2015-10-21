
{ log, p, pjson } = require 'lightsaber'
{ address } = require 'bitcoinjs-lib'
ApplicationController = require './state-application-controller'
DcoCollection = require '../collections/dco-collection'
ShowView = require '../views/users/show-view'
BtcView = require '../views/users/btc-view'
SetDcoView = require '../views/users/set-dco-view'

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
    if dcoId = params.id
      @currentUser.setDcoTo(dcoId).then =>
        @msg.send "Community set to #{dcoId}"
        @currentUser.exit()
        @redirect()

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
