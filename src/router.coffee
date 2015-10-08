{ log, p, pjson } = require 'lightsaber'
User = require './models/user'
InitialStateController = require './controllers/initial-state-controller'
ProposalsStateController = require './controllers/proposals-state-controller'

class Router
  route: (msg)->
    User.find msg.robot.whose(msg)
    .then (user) ->
      p user.get('state')
      switch user.get('state')
        when 'none'      then new InitialStateController(msg, user).process()
        when 'proposals' then new ProposalsStateController(msg, user).process()

module.exports = new Router()
