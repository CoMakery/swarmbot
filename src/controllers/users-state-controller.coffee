
{ log, p, pjson } = require 'lightsaber'
{ address } = require 'bitcoinjs-lib'
{ filter, any } = require 'lodash'

swarmbot = require '../models/swarmbot'
ApplicationController = require './application-state-controller'
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
    dcoId = params.id
    @currentUser.setDcoTo(dcoId).then =>
      @currentUser.exit()
      @redirect("Community set to #{dcoId}")

  myAccount: ->
    # show current user data
    if userAddress = @currentUser.get('btc_address')
      colu = swarmbot.colu().then (colu) ->

        colu.getTransactions (err, txs) ->
          p err if err
          # p txs[0]
          myTxs = filter txs, (tx) ->
            tx['colored'] is true and
            any tx['vout'], (vout) ->
              any vout['scriptPubKey']['addresses'], (address) ->
                address == userAddress

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
