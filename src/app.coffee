{ json, log, p, pjson, type } = require 'lightsaber'
{ defaults, isEmpty } = require 'lodash'
Promise = require 'bluebird'
debug = require('debug')('app')
errorLog = require('debug')('error')
inspectFallback = require('debug')('fallback')

User = require './models/user'
controllers =
  projects:    require './controllers/projects-state-controller'
  rewards:     require './controllers/rewards-state-controller'
  rewardTypes: require './controllers/reward-types-state-controller'
  users:       require './controllers/users-state-controller'

class App
  @COIN = '❂'
  @MAX_SLACK_IMAGE_SIZE = Math.pow 2,19
  @SLACK_NON_TEXT_FIELDS = [
    'author_icon'
    'color'
    'short'
  ]

  @respond: (pattern, cb)->
    @responses ?= []
    @responses.push [pattern, cb]

  @respondTo: (msg)->
    @route(msg)
    .then (textOrAttachments)=> @addFallbackTextIfNeeded textOrAttachments

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
        errorLog errorMessage
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

  @pmReply: (msg, textOrAttachments)=>
    channel = msg.message.user.name
    @sendMessage channel, textOrAttachments

  @sendMessage: (channel, textOrAttachments)=>
    if type(textOrAttachments) is 'string'
      @robot.messageRoom(channel, textOrAttachments)
    else if type(textOrAttachments) in ['array', 'object']
      @sendAttachmentMessage(channel, textOrAttachments)
    else
      throw new Error "Unexpected type(textOrAttachments) -> #{type(textOrAttachments)}"

  @sendAttachmentMessage: (channel, attachment)=>
    @robot.adapter.customMessage
      channel: channel
      attachments: attachment

  @addFallbackTextIfNeeded: (textOrAttachments)->
    if type(textOrAttachments) is 'string'
      textOrAttachments
    else if type(textOrAttachments) is 'object'
      @fallbackForAttachment(textOrAttachments)
    else if type(textOrAttachments) is 'array'
      for attachment in textOrAttachments
        @fallbackForAttachment(attachment)

  @fallbackForAttachment: (attachment)->
    if isEmpty attachment.fallback?.trim()
      inspectFallback "Attachment:\n#{pjson attachment}"
      fallbackText = @extractTextLines(attachment).join("\n")
      inspectFallback "Fallback text:\n#{fallbackText}"
      attachment.fallback = fallbackText
    else
      inspectFallback "Attachment arrived with fallback already set:\n#{pjson attachment}"
    attachment

  @extractTextLines: (element)->
    lines = []
    if type(element) is 'array'
      for item in element
        lines.push @extractTextLines(item)...
    else if type(element) is 'object'
      for key, value of element
        if (key not in @SLACK_NON_TEXT_FIELDS) and value
          lines.push @extractTextLines(value)...
    else if type(element) is 'string'
      lines.push element
    else
      throw new Error "Unexpected attachment chunk type: '#{type(element)}' for #{pjson element}"
    lines

  @registerUser: (user, msg)->
    attributes = {}
    unless user.get "slackUsername"
      slackUsername = msg.message.user.name
      slackId = msg.message.user.id
      realName = msg.message.user.real_name
      emailAddress = msg.message.user.email_address

      attributes.slackUsername = slackUsername if slackUsername
      attributes.firstSeen = Date.now() if slackUsername
      attributes.realName = realName if realName
      attributes.emailAddress = emailAddress if emailAddress
      attributes.slackId = slackId if slackId
    attributes.lastActiveOnSlack = Date.now()
    attributes.state = User::initialState unless user.get 'state'

    user.update attributes

  @greet = (res)->
    currentUser = new User name: App.robot.whose(res)
    currentUser.fetch()
    .then (@user)=> @user.set('state', 'users#welcome')   # goes away if this is new home page
    .then => App.route res
    .then (welcome)=>
      App.pmReply res, welcome
      @user.set 'state', User::initialState
    .then => App.route res
    .then (projects)=> App.pmReply res, projects

module.exports = App
