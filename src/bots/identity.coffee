# Description:
#   User / account managemnet
#
# Commands:
#   hubot register <btc_address>

# Hidden Commands:

#   hubot set community <current community>
#   hubot unset community
#   hubot about me
#   hubot about <slack username>

# Not in use:
#   hubot register email <email>

{ p, log } = require 'lightsaber'
{ values } = require 'lodash'
UsersController = require '../controllers/users-controller'
swarmbot = require '../models/swarmbot'
User = require '../models/user'
DCO = require '../models/dco'
inspect = require('util').inspect

module.exports = (robot) ->

  robot.enter (msg) ->
    try
      greet(msg, msg.message.user.name, true, robot)
    catch error

  robot.respond /help\s*/i, (msg) ->
    log "MATCH 'help' "
    try
      greet(msg, msg.message.user.name, true, robot)
    catch error


  # Generic auto register
  robot.respond /\s*/i, (msg) ->
    new UsersController().register(msg)

  # Deprecate register me now that we have auto-registration
  # robot.respond /register me$/i, (msg) ->
  #   new UsersController().register(msg)

  robot.respond /register <?(\w+)>?$/i, (msg) ->
    log "MATCH 'register' : #{msg.match[0]}"
    btcAddress = msg.match[1]
    new UsersController().registerBtc(msg, { btcAddress })

  robot.respond /set community\s+(.+)\s*$/i, (msg) ->
    log "MATCH 'set community' : #{msg.match[0]}"
    community = msg.match[1]
    new UsersController().setCommunity(msg, { community })

  robot.respond /unset community\s*$/i, (msg) ->
    log "MATCH 'unset community' : #{msg.match[0]}"
    new UsersController().unsetCommunity(msg)

  robot.respond /about (.*)\s*$/i, (msg) ->
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

  # Not sure, this may work in slack, not sure about
  #  robot.respond /register?.*/i, (msg) ->
  #    robot.reply 'some msg'?

  # robot.respond /register email (.+)$/i, (msg) ->
  #   msg.match.shift()
  #   [emailAddress] = msg.match
  #   activeUser = robot.whose msg
  #   user = User.find activeUser
  #   user.register "email_address", emailAddress

    #TODO: would  be nice to send out an outbound email notification that then allows them to setup a BTC wallet
    # something like the Mandril usage we have in the Swarm API
    # https://swarm-rome.herokuapp.com/messages/send-template

    # msg.send "Email registered"
