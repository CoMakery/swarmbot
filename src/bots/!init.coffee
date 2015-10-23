# Description:
#   Initialize the bot.
#   Note: this file name starts with a special character in order to load first;
#   Hubot loads scripts in sorted order.
#
# Commands:
#

{ json, log, p, pjson } = require 'lightsaber'
Promise = require 'bluebird'
trustExchange = require('trust-exchange').instance
swarmbot = require '../models/swarmbot'
User = require '../models/user'
global.App = require '../app'

# Promise.longStackTraces() # only in development mode. decreases performance 5x

if process.env.FIREBASE_SECRET?
  swarmbot.firebase().authWithCustomToken process.env.FIREBASE_SECRET, (error) ->
    p error

trustExchange.configure
  adaptors:
    firebase: swarmbot.firebase()

InitBot = (robot) ->
  throw new Error if robot.whose? || robot.currentUser?
  robot.whose = (msg) -> "slack:#{msg.message.user.id}"

  robot.pm = (msg, text) -> robot.messageRoom msg.message.user.name, text

  # State-based message routing
  robot.respond /(.*)/, (msg) ->
    App.route(msg).then (response) -> msg.send response

  robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
    p "HTTP webhook received", req, res

  robot.respond /what data\?$/i, (msg) ->
    p pjson msg
    msg.send 'check the logs'

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
