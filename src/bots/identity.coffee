# Commands:

{ p, log } = require 'lightsaber'
{ values } = require 'lodash'
UsersController = require '../controllers/users-controller'
swarmbot = require '../models/swarmbot'
User = require '../models/user'
DCO = require '../models/dco'
inspect = require('util').inspect

module.exports = (robot)->

  App.respond /about (.*)\s*$/i, (msg)->
    log "MATCH 'about' : #{msg.match[0]}"
    slackUsername = msg.match[1]
    new UsersController().getInfo(msg, { slackUsername })
