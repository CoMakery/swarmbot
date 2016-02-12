{ json, log, p, pjson } = require 'lightsaber'

Firebase = require 'firebase'
Colu = require 'colu'

class Swarmbot
  firebase: ->
    @_firebase ?= new Firebase process.env.FIREBASE_URL

  colu: ->
    return Promise.resolve(@_colu) if @_colu?

    coluParams =
      network: process.env.COLU_NETWORK
      privateSeed: process.env.COLU_PRIVATE_SEED
      privateSeedWif: process.env.COLU_PRIVATE_SEED_WIF
      oldPrivateSeed: process.env.COLU_OLD_PRIVATE_SEED_WIF
      apiKey: process.env.COLU_MAINNET_APIKEY
    if process.env.REDISTOGO_URL
      coluParams.redisUrl = process.env.REDISTOGO_URL
    if process.env.REDIS_HOST
      coluParams.redisHost = process.env.REDIS_HOST
    if process.env.REDIS_PORT
      coluParams.redisPort = process.env.REDIS_PORT

    @_colu = new Colu coluParams
    return new Promise (resolve)=>
      @_colu.on 'connect', => resolve @_colu
      @_colu.init()

  coluExplorerUrl: ->
    testnet = if process.env.COLU_NETWORK is 'testnet' then "testnet." else ""
    "https://#{testnet}explorer.coloredcoins.org"

module.exports = new Swarmbot
