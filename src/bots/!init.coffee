# Description:
#   Initialize the bot.
#   Note: this file name starts with a special character in order to load first;
#   Hubot loads scripts in sorted order.
#
# Commands:
#

if process.env.AIRBRAKE_API_KEY
  airbrake = require('airbrake').createClient(process.env.AIRBRAKE_API_KEY)
  airbrake.handleExceptions()

debug = require('debug')('app')
{ json, log, p, pjson, type } = require 'lightsaber'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
User = require '../models/user'
global.App = require '../app'
UsersController = require '../controllers/users-controller'
ZorkHelper = require '../helpers/zork-helper'

App.airbrake = airbrake

process.on 'unhandledRejection', (error, promise) ->
  throw error unless App.airbrake
  console.error 'Unhandled rejection: ' + (error and error.stack or error)
  App.airbrake.notify error, (airbrakeNotifyError, url) ->
    if airbrakeNotifyError
      throw airbrakeNotifyError
    else
      debug "Delivered to #{url}"
      throw error

Promise.longStackTraces() if process.env.NODE_ENV is 'development' # decreases performance 5x

if process.env.FIREBASE_SECRET?
  swarmbot.firebase().authWithCustomToken process.env.FIREBASE_SECRET, (error) ->
    p error

InitBot = (robot) ->
  App.robot = robot
  robot.router.use(App.airbrake.expressHandler()) if App.airbrake  # do we need this?

  robot.whose = (msg) -> "slack:#{msg.message.user.id}"

  robot.pmReply = (msg, textOrAttachments) ->
    channel = msg.message.user.name
    if type(textOrAttachments) is 'string'
      robot.messageRoom channel, textOrAttachments
    else if type(textOrAttachments) in ['array', 'object']
      robot.adapter.customMessage
        channel: channel
        attachments: textOrAttachments
    else
      throw new Error "Unexpected type(textOrAttachments) -> #{type(textOrAttachments)}"

  robot.isPublic = (msg) -> msg.message.room isnt msg.message.user?.name

  robot.slack = robot.adapter.client # TODO: Detect if this actually is a slack adapter.

  # State-based message routing
  robot.respond /(.*)/, (msg) ->
    if robot.isPublic msg
      msg.reply "Let's take this offline.  I PM'd you :smile:"
    App.route(msg).then (response) ->
      robot.pmReply msg, response

  robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
    p "HTTP webhook received", req, res

  App.respond /what data\?$/i, (msg) ->
    p pjson msg
    msg.send 'check the logs'

  robot.enter (res) -> greet res

  greet = (res) ->
    # robot.pmReply (new GeneralStateController).welcome()
    # robot.pmReply (new WelcomeView).render()

    robot.pmReply res, [
      ZorkHelper::body "
        Hi there!  My name is Swarmbot, and I'm here to help you
        create projects for things that you want to collaborate on,
        and assign rewards to people who do them!
        "
      ZorkHelper::body """
        You can create a new project by typing:
        `create project <My Awesome Project>`
        """
      ZorkHelper::body "
        Here is a list of projects others have already created
        that you may like to collaborate on...
        "
      ]

    currentUser = new User name: robot.whose(res)
    currentUser.fetch()
    .then (user) -> user.set('state', 'users#setDco')   # goes away if this is new home page
    .then -> App.route res
    .then (projects) -> robot.pmReply res, projects

  App.respond /welcome me$/i, (msg) ->
    greet msg

  # Generic auto register
  autoRegisterUser = (msg) -> new UsersController().register(msg)

  robot.enter (res) -> autoRegisterUser msg

module.exports = InitBot

# On the msg object:
# robot: [Object]
# message:
#    { user: { id: 1, name: 'Shell', room: 'Shell' },
#      text: 'swarmbot rate xyz bounty excellence2 50%',
#      id: 'messageId',
#      done: false,
#      room: 'Shell' },
#   match:
#    [ 'swarmbot rate xyz bounty excellence2 50%',
#      'xyz',
#      'excellence2',
#      '50',
#      index: 0,
#      input: 'swarmbot rate xyz bounty excellence2 50%' ],
#   envelope:
#    { room: 'Shell',
#      user: { id: 1, name: 'Shell', room: 'Shell' },
#      message:
#       { user: [Object],
#         text: 'swarmbot rate xyz bounty excellence2 50%',
#         id: 'messageId',
#         done: false,
#         room: 'Shell' } } }
