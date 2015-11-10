# Commands:

{ p, log } = require 'lightsaber'
{ values } = require 'lodash'
UsersController = require '../controllers/users-controller'
swarmbot = require '../models/swarmbot'
User = require '../models/user'
DCO = require '../models/dco'
inspect = require('util').inspect

module.exports = (robot) ->

  App.respond /about (.*)\s*$/i, (msg) ->
    log "MATCH 'about' : #{msg.match[0]}"
    slackUsername = msg.match[1]
    new UsersController().getInfo(msg, { slackUsername })

greet = (msg, username, privateMessage, robot) ->

  hubot_username = 'imgflip_hubot'
  hubot_password = 'imgflip_hubot'

  msg.http('https://api.imgflip.com/caption_image')
  .query
    template_id: 6624009,
    username: hubot_username,
    password: hubot_password,
    text0: "hello " + username,
    text1: "Im Nyan"
  .post() (error, res, body) ->
    if error
      p "I got an error when talking to imgflip:", inspect(error)
      msg.reply "Hello I'm Nyan"
      return

    result = JSON.parse(body)
    success = result.success
    errorMessage = result.error_message

    if not success
      msg.reply "Imgflip API request failed: #{errorMessage}"
      p "FAIL"
      return

    helpMessage = "Type 'bounties' to see active bounties\n"
    helpMessage += "Type 'register <my_bitcoin_address> to start getting bounties\n"
    helpMessage += "Type 'proposals' to see proposals\n"
    helpMessage += "Type 'propose <proposal_name> for <number> bucks' to create a new proposal\n"
    helpMessage += "Type 'more commands' to see other suggested commands\n"

    if (privateMessage)
      robot.messageRoom username, result.data.url
      # robot.messageRoom msg.message.user.name, "Hello I'm Nyan!"
      robot.messageRoom username, helpMessage
    else
      msg.send result.data.url
      msg.send helpMessage
