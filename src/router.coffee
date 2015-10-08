{ log, p, pjson } = require 'lightsaber'
User = require './models/user'
InitialStateController = require './controllers/initial-state-controller'
ProposalsStateController = require './controllers/proposals-state-controller'

class Router
  setCurrentUser: (msg)->
    msg.currentUser ?= new User id: msg.robot.whose(msg)

  route: (msg)->
    @setCurrentUser(msg)

    msg.currentUser.fetchIfNeeded()
    .then (user) =>
      switch user.current
        when 'home', 'proposals-index', 'proposals-show'
          new ProposalsStateController(@, msg).process()
        else
          p 'no route!'

module.exports = new Router()
