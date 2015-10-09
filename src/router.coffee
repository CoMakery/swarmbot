{ log, p, pjson } = require 'lightsaber'
User = require './models/user'
InitialStateController = require './controllers/initial-state-controller'
ProposalsStateController = require './controllers/proposals-state-controller'

class Router
  route: (msg)->
    @setCurrentUser(msg)

    msg.currentUser.fetchIfNeeded()
    .then (user) =>
      p "\nmessage: #{msg.match[1]}"
      p "user: #{user.get('slack_username')}"
      p "state: #{user.current}"

      switch user.current
        when 'home', 'proposals-index', 'proposals-show'
          new ProposalsStateController(@, msg).process()
        else
          p 'no route!'

  setCurrentUser: (msg)->
    msg.currentUser ?= new User id: msg.robot.whose(msg)

module.exports = new Router()
