# Description:
#   Initialize the bot.
#   Note: this file name starts with a special character in order to load first;
#   Hubot loads scripts in sorted order.
#
# Commands:
#

{ json, log, p, pjson } = require 'lightsaber'
trustExchange = require('trust-exchange').instance
swarmbot = require '../models/swarmbot'
Promise = require 'bluebird'

Promise.longStackTraces() # TODO: only in development mode. decreases performance 5x

trustExchange.configure
  adaptors:
    firebase: swarmbot.firebase()

if process.env.FIREBASE_SECRET?
  swarmbot.firebase().authWithCustomToken process.env.FIREBASE_SECRET, (error) ->
    p error

InitBot = (robot) ->
  throw new Error if robot.whose?
  robot.whose = (room) -> "slack:#{room.message.user.id}"

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
