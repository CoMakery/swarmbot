{ json, log, p, pjson } = require 'lightsaber'

# Promise = require 'bluebird'
# Firebase = Promise.promisifyAll require 'firebase'
Firebase = require 'firebase'
Colu = require 'colu'

class Swarmbot

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
    @_colu = new Colu coluParams

module.exports = new Swarmbot
