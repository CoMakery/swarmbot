{ d, json, log, p, pjson, type } = require 'lightsaber'
{ defaults, isEmpty, merge } = require 'lodash'

swarmbot = require './models/swarmbot'
KeenioInfo = require './services/keenio-info.coffee'
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

  @init: (@robot)->
    @slack = @robot.adapter.client
    @authFirebase()
    @robot.respond /(.*)/, (msg)=> @respondAndReply msg   # custom catch-all routing
    @robot.enter (res)=> @greet res  # greet new users

  @respondAndReply: (msg)->
    @respondTo(msg).then (reply)=>
      debugReply pjson reply
      @pmReply msg, reply
    if @isPublic msg
      msg.reply "Let's take this offline.  I PM'd you :smile:"

  @authFirebase: ->
    if process.env.FIREBASE_SECRET?
      swarmbot.firebase().authWithCustomToken process.env.FIREBASE_SECRET, (error)->
        throw error

  @whose: (msg)-> "slack:#{msg.message.user.id}"

  @isPublic: (msg)-> msg.message.room isnt msg.message.user?.name

  @addResponder: (pattern, cb)->
    @responses ?= []
    @responses.push [pattern, cb]

  @respondTo: (msg)->
    @route(msg)
    .then (textOrAttachments)=> @addFallbackTextIfNeeded textOrAttachments

  @route: (msg)->
    debug "in @route: msg.match?[1] => #{msg.match?[1]}"

    # commands that were added with @addResponder:

    if @responses? and input = msg.match[1]
      for [pattern, cb] in @responses
        if match = input.match pattern
          msg.match = msg.message.match(pattern)
          return new Promise (resolve, reject)=>
            debug "Command: `#{input}`, Matched: #{pattern}"
            cb(msg)
            resolve('')

    # custom routing, using controllers, menus, etc:

    msg.currentUser ?= new User name: @whose(msg)
    msg.currentUser.fetch()
    .then (@user)=>
      @registerUser @user, msg.message.user, @user.newRecord()
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

  @registerUser: (user, slackUser, newRecord)->
    attributes =
      lastActiveOnSlack: Date.now()
      state: user.get('state') or User::initialState

    if newRecord
      slackUsername = slackUser.name
      slackId = slackUser.id
      realName = slackUser.real_name
      emailAddress = slackUser.email_address

      attributes.slackUsername = slackUsername if slackUsername
      attributes.firstSeen = Date.now()
      attributes.realName = realName if realName
      attributes.emailAddress = emailAddress if emailAddress
      attributes.slackId = slackId if slackId

    user.update attributes
    .then (user)=>
      if newRecord
        (new KeenioInfo()).createUser(user)
      user

  @greet = (res)->
    currentUser = new User name: @whose(res)
    currentUser.fetch()
    .then (@user)=> @user.set('state', 'users#welcome')   # goes away if this is new home page
    .then => @route res
    .then (welcome)=>
      @pmReply res, welcome
      @user.set 'state', User::initialState
    .then => @route res
    .then (projects)=> @pmReply res, projects

module.exports = App
