{ json, log, p, pjson } = require 'lightsaber'

Firebase = require 'firebase'
Colu = require 'colu'

class Swarmbot
  feedbackDcokey: 'swarmbot-lovers'

  firebase: ->
    @_firebase ?= new Firebase process.env.FIREBASE_URL

  colu: ->
    return @_colu if @_colu?

    coluParams =
      network: process.env.COLU_NETWORK
      privateSeed: process.env.COLU_PRIVATE_SEED
      apiKey: process.env.COLU_MAINNET_APIKEY
    if process.env.REDIS_HOST
      coluParams.redisHost = process.env.REDIS_HOST
    if process.env.REDIS_PORT
      coluParams.redisPort = process.env.REDIS_PORT

    @_colu = new Colu coluParams
    @_colu.init()
    @_colu

module.exports = new Swarmbot
