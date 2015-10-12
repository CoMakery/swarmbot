{ log, p, pjson } = require 'lightsaber'
User = require './models/user'
ProposalsStateController = require './controllers/proposals-state-controller'

class Router
  route: (msg) ->
    @setCurrentUser msg
    msg.currentUser.fetch()
    .then (user) =>
      p "state: #{user.current}"
      switch user.current
        when 'home', 'proposalsShow', 'proposalsCreate', 'solutionsCreate'
          new ProposalsStateController(@, msg).process()
        else
          p "Unexpected user state #{user.current} -- resetting to default state"
          user.set 'state', 'home'
          .then => @route msg

  setCurrentUser: (msg) ->
    msg.currentUser ?= new User id: msg.robot.whose(msg)

module.exports = new Router()
