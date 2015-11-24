{ json, log, p, pjson } = require 'lightsaber'
Promise = require 'bluebird'

Firebase = require 'firebase'
Colu = require 'colu'

class Swarmbot
  feedbackDcokey: 'swarmbot-lovers'

  firebase: ->
    @_firebase ?= new Firebase process.env.FIREBASE_URL

  colu: ->
    return Promise.resolve(@_colu) if @_colu?

    coluParams =
      network: process.env.COLU_NETWORK
      privateSeed: process.env.COLU_PRIVATE_SEED
      apiKey: process.env.COLU_MAINNET_APIKEY
    if process.env.REDISTOGO_URL
      coluParams.redisUrl = process.env.REDISTOGO_URL
    if process.env.REDIS_HOST
      coluParams.redisHost = process.env.REDIS_HOST
    if process.env.REDIS_PORT
      coluParams.redisPort = process.env.REDIS_PORT

    @_colu = new Colu coluParams
    return new Promise (resolve) =>
      @_colu.on 'connect', =>
        (require('debug')('privatekey'))( @_colu.hdwallet.getPrivateSeed() ) unless process.env.COLU_PRIVATE_SEED
        resolve @_colu
      @_colu.init()

  coluExplorerUrl: ->
    testnet = if process.env.COLU_NETWORK == 'testnet' then "testnet." else ""
    "https://#{testnet}explorer.coloredcoins.org"

module.exports = new Swarmbot
