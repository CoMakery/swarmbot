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
{ merge } = require 'lodash'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
User = require '../models/user'
global.App = require '../app'

App.airbrake = airbrake

process.on 'unhandledRejection', (error, promise)->
  throw error unless App.airbrake
  console.error 'Unhandled rejection: ' + (error and error.stack or error)
  App.airbrake.notify error, (airbrakeNotifyError, url)->
    if airbrakeNotifyError
      throw airbrakeNotifyError
    else
      debug "Delivered to #{url}"
      throw error

Promise.longStackTraces() if process.env.NODE_ENV is 'development' # decreases performance 5x

if process.env.FIREBASE_SECRET?
  swarmbot.firebase().authWithCustomToken process.env.FIREBASE_SECRET, (error)->
    p error

InitBot = (robot)->
  App.robot = robot
  robot.router.use(App.airbrake.expressHandler()) if App.airbrake  # do we need this?

  robot.whose = (msg)-> "slack:#{msg.message.user.id}"

  robot.isPublic = (msg)-> msg.message.room isnt msg.message.user?.name

  robot.slack = robot.adapter.client # TODO: Detect if this actually is a slack adapter.

  # State-based message routing
  robot.respond /(.*)/, (msg)->
    if robot.isPublic msg
      msg.reply "Let's take this offline.  I PM'd you :smile:"
    App.route(msg).then (response)->
      App.pmReply msg, response

  App.respond /what data\? WxmhxTuxKfjnVQ3mLgGZaG2KPn$/i, (msg)->
    p pjson msg
    msg.send 'check the logs'

  robot.enter (res)-> greet res

  greet = (res)->
    currentUser = new User name: robot.whose(res)
    currentUser.fetch()
    .then (@user)=> @user.set('state', 'users#welcome')   # goes away if this is new home page
    .then => App.route res
    .then (welcome)=>
      App.pmReply res, welcome
      @user.set 'state', 'users#setProject'    # goes away if this becomes the new home page
    .then => App.route res
    .then (projects)=> App.pmReply res, projects

  App.respond /welcome me WxmhxTuxKfjnVQ3mLgGZaG2KPn$/i, (msg)-> greet msg

module.exports = InitBot
