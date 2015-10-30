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
      [_, host, port] = process.env.REDISTOGO_URL.match /redis:\/\/(.+:.+@.+):(\d+)/
      process.env.REDIS_HOST = host
      process.env.REDIS_PORT = port
    if process.env.REDIS_HOST
      coluParams.redisHost = process.env.REDIS_HOST
    if process.env.REDIS_PORT
      coluParams.redisPort = process.env.REDIS_PORT

    @_colu = new Colu coluParams
    promise = new Promise (resolve) =>
      @_colu.on 'connect', =>
        resolve @_colu
    @_colu.init()
    promise

module.exports = new Swarmbot
