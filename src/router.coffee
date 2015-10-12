{ log, p, pjson } = require 'lightsaber'
User = require './models/user'
InitialStateController = require './controllers/initial-state-controller'
ProposalsStateController = require './controllers/proposals-state-controller'

class Router
  route: (msg)->
    @setCurrentUser(msg)

    msg.currentUser.fetchIfNeeded()
    .then (user) =>
      p "state: #{user.current}"

      switch user.current
        when 'home', 'proposalsIndex', 'proposalsShow', 'proposalsCreate'
          new ProposalsStateController(@, msg).process()
        else
          throw new Error "No route! for state #{user.current}"
          # TODO: set to home, show help

  setCurrentUser: (msg)->
    msg.currentUser ?= new User(id: msg.robot.whose(msg))

module.exports = new Router()
