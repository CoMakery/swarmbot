{ json, log, p, pjson } = require 'lightsaber'
Promise = require 'bluebird'
debug = require('debug')('app')
User = require './models/user'
controllers =
  rewardTypes: require './controllers/reward-types-state-controller'
  general:     require './controllers/general-state-controller'
  projects:        require './controllers/projects-state-controller'
  users:       require './controllers/users-state-controller'
  rewards:     require './controllers/rewards-state-controller'

class App
  @COIN = '❂'
  @MAX_SLACK_IMAGE_SIZE = Math.pow 2,19

  @respond: (pattern, cb)->
    @responses ?= []
    @responses.push [pattern, cb]

  @route: (msg)->
    debug "in @route: msg.match?[1] => #{msg.match?[1]}"

    # old commands:

    if @responses? and input = msg.match[1]
      for [pattern, cb] in @responses
        if match = input.match pattern
          msg.match = msg.message.match(pattern)
          return new Promise (resolve, reject)=>
            debug "Command: `#{input}`, Matched: #{pattern}"
            cb(msg)
            resolve('')

    # otherwise do Zork MVC routing:

    msg.currentUser ?= new User name: msg.robot.whose(msg)
    msg.currentUser.fetch()
    .then (@user)=>
      @registerUser @user, msg
    .then (@user)=>
      debug "state: #{@user.get 'state'}"
      [controllerName, action] = @user.get('state').split('#')

      controllerClass = controllers[controllerName]
      controller = new controllerClass(msg) if controllerClass?
      unless controller and controller[action]
        errorMessage = "Unexpected @user state #{@user.get('state')} -- resetting to default state"
        msg.send("*#{errorMessage}*") if process.env.NODE_ENV is 'development'
        console.error errorMessage
        return @user.set('state', User::initialState)
          .then => @route(msg)

      controller.input = msg.match[1]

      lastMenuItems = @user.get('menu')
      menuAction = lastMenuItems?[controller.input?.toLowerCase()]

      if menuAction?
        # specific menu action of entered command
        debug "Command: #{controller.input}, controllerName: #{controllerName}, menuAction: #{json menuAction}"
        controller.execute(menuAction)
      else if controller[action]?
        # default action for this state
        debug "Command: #{controller.input}, controllerName: #{controllerName}, action: #{action}"
        controller[action]( @user.get('stateData') )
      else
        throw new Error("Action for state '#{@user.get('state')}' not defined.")


  @registerUser: (user, msg)->
    attributes = {}
    unless user.get "slack_username"
      slackUsername = msg.message.user.name
      slackId = msg.message.user.id
      realName = msg.message.user.real_name
      emailAddress = msg.message.user.email_address

      attributes.slack_username = slackUsername if slackUsername
      attributes.first_seen = Date.now() if slackUsername
      attributes.real_name = realName if realName
      attributes.email_address = emailAddress if emailAddress
      attributes.slack_id = slackId if slackId
    attributes.last_active_on_slack = Date.now()
    attributes.state = User::initialState unless user.get 'state'

    user.update attributes

module.exports = App
