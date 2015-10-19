{ log, p, pjson } = require 'lightsaber'
debug = require('debug')('app')
User = require './models/user'
controllers =
  proposals: require './controllers/proposals-state-controller'
  general:   require './controllers/general-state-controller'
  dcos:      require './controllers/dcos-state-controller'
  users:     require './controllers/users-state-controller'
  solutions: require './controllers/solutions-state-controller'

class App
  @route: (msg) ->
    @setCurrentUser msg
    msg.currentUser.fetch()
    .then (user) =>
      debug "state: #{user.current}"
      [controllerName, action] = user.current.split('#')

      controllerClass = controllers[controllerName]
      controller = new controllerClass(msg) if controllerClass?
      unless controller and controller[action]
        console.error "Unexpected user state #{user.current} --
          resetting to default state"
        return user.set('state', 'general#home').then => @route(msg)

      controller.input = msg.match[1]
      lastMenuItems = user.get('menu')
      menuAction = lastMenuItems?[controller.input?.toLowerCase()]
      if menuAction?
        # specific menu action of entered command
        controller.execute(menuAction)
      else if controller[action]?
        # default action for this state
        controller[action]( user.get('stateData') )
      else
        throw new Error("Action for state '#{user.current}' not defined.")

  @setCurrentUser: (msg) ->
    msg.currentUser ?= new User id: msg.robot.whose(msg)

module.exports = App
