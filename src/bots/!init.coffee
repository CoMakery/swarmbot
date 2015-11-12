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

{ json, log, p, pjson } = require 'lightsaber'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
User = require '../models/user'
global.App = require '../app'
UsersController = require '../controllers/users-controller'

App.airbrake = airbrake

Promise.longStackTraces() if process.env.NODE_ENV is 'development' # decreases performance 5x

if process.env.FIREBASE_SECRET?
  swarmbot.firebase().authWithCustomToken process.env.FIREBASE_SECRET, (error) ->
    p error

InitBot = (robot) ->
  App.robot = robot
  robot.router.use(App.airbrake.expressHandler()) if App.airbrake

  robot.whose = (msg) -> "slack:#{msg.message.user.id}"

  robot.pmReply = (msg, text) -> robot.messageRoom msg.message.user.name, text

  robot.isPublic = (msg) -> msg.message.room isnt msg.message.user?.name

  # State-based message routing
  robot.respond /(.*)/, (msg) ->
    autoRegisterUser msg
    if robot.isPublic msg
      msg.reply "Let's take this offline.  I PM'd you :smile:"
    App.route(msg).then (response) -> robot.pmReply msg, response

  robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
    p "HTTP webhook received", req, res

  App.respond /what data\?$/i, (msg) ->
    p pjson msg
    msg.send 'check the logs'

  # Generic auto register
  autoRegisterUser = (msg) -> new UsersController().register(msg)

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
