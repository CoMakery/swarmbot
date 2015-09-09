{ json, log, p, pjson } = require 'lightsaber'

Firebase = require 'firebase'
Colu = require 'colu'

class Swarmbot

  configure: ->
    @firebase = new Firebase process.env.FIREBASE_URL
    @colu = new Colu
      network: process.env.COLU_NETWORK
      privateSeed: process.env.COLU_PRIVATE_SEED

module.exports = new Swarmbot
