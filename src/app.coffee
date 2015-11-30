{ log, p, pjson } = require 'lightsaber'
Promise = require 'bluebird'
debug = require('debug')('app')
User = require './models/user'
controllers =
  proposals: require './controllers/proposals-state-controller'
  general:   require './controllers/general-state-controller'
  dcos:      require './controllers/dcos-state-controller'
  users:     require './controllers/users-state-controller'
  solutions: require './controllers/solutions-state-controller'

class App
  @MAX_SLACK_IMAGE_SIZE = Math.pow 2,19

  @respond: (pattern, cb) ->
    @responses ?= []
    @responses.push [pattern, cb]

  @route: (msg) ->
    debug "in @route: msg.match?[1] => #{msg.match?[1]}"

    # old commands:

    if @responses? and input = msg.match[1]
      for [pattern, cb] in @responses
        if match = input.match pattern
          msg.match = msg.message.match(pattern)
          return new Promise (resolve, reject) =>
            debug "Command: `#{input}`, Matched: #{pattern}"
            cb(msg)
            resolve('')

    # otherwise do Zork MVC routing:
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
        debug "Command: #{controller.input}, controllerName: #{controllerName}, menuAction: #{menuAction}"
        controller.execute(menuAction)
      else if controller[action]?
        # default action for this state
        debug "Command: #{controller.input}, controllerName: #{controllerName}, action: #{action}"
        controller[action]( user.get('stateData') )
      else
        throw new Error("Action for state '#{user.current}' not defined.")

  @setCurrentUser: (msg) ->
    msg.currentUser ?= new User name: msg.robot.whose(msg)

module.exports = App
