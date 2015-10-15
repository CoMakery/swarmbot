{ log, p, pjson } = require 'lightsaber'
User = require './models/user'
ProposalsStateController = require './controllers/proposals-state-controller'
GeneralStateController = require './controllers/general-state-controller'
DcosStateController = require './controllers/dcos-state-controller'
UsersStateController = require './controllers/users-state-controller'

class Router
  route: (msg) ->
    @setCurrentUser msg
    msg.currentUser.fetch()
    .then (user) =>
      p "state: #{user.current}"
      switch user.current
        when 'home', 'proposalsShow', 'proposalsCreate', 'solutionsCreate'
          new ProposalsStateController(@, msg).process()
        when 'moreCommands'
          new GeneralStateController(@, msg).process()
        when 'dcosSet'
          new DcosStateController(@, msg).process()
        when 'myAccount', 'setBtc'
          new UsersStateController(@, msg).process()
        else
          console.error "Unexpected user state #{user.current} -- resetting to default state"
          user.set('state', 'home').then => @route msg

  setCurrentUser: (msg) ->
    msg.currentUser ?= new User id: msg.robot.whose(msg)

module.exports = new Router()
