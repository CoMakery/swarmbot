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
    p "help"
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

      # msg.send "greeting you"

      # p "msg", msg
      p "usr", username
      username = 'imgflip_hubot'
      password = 'imgflip_hubot'

      p "greet"

      msg.http('https://api.imgflip.com/caption_image')
      .query
          template_id: 6624009,
          username: username,
          password: password,
          text0: "hello " + username,
          text1: "Im Nyan"
      .post() (error, res, body) ->
        if error
          p "I got an error when talking to imgflip:", inspect(error)
          msg.reply "Hello I'm Nyan"
          return

        result = JSON.parse(body)
        p "result", result
        success = result.success
        errorMessage = result.error_message

        if not success
          msg.reply "Imgflip API request failed: #{errorMessage}"
          p "FAIL"
          return

        if (privateMessage)
          robot.messageRoom username, result.data.url
          # robot.messageRoom msg.message.user.name, "Hello I'm Nyan!"
          robot.messageRoom username, "Type 'bounties' to see active bounties"
          robot.messageRoom username, "Type 'register <my_bitcoin_address> to start getting bounties"
          robot.messageRoom username, "Type 'proposals' to see proposals"
          robot.messageRoom username, "Type 'propose <proposal_name> for <number> bucks' to create a new proposal"
          robot.messageRoom username, "Type 'more commands' to see other suggested commands"
        else
          msg.send "yo"
          msg.send result.data.url
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
