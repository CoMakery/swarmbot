{ json, log, p, pjson } = require 'lightsaber'

# Promise = require 'bluebird'
# Firebase = Promise.promisifyAll require 'firebase'
Firebase = require 'firebase'
Colu = require 'colu'

class Swarmbot

  firebase: ->
    @_firebase ?= new Firebase process.env.FIREBASE_URL

  colu: ->
    @_colu ?= new Colu
      network: process.env.COLU_NETWORK
      privateSeed: process.env.COLU_PRIVATE_SEED
      apiKey: process.env.COLU_MAINNET_APIKEY


module.exports = new Swarmbot
