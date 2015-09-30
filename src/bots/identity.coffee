# Description:
#   User / account managemnet
#
# Commands:
#   hubot register btc <btc_address>
#   hubot set community <current community>
#   hubot unset community
#   hubot about me
#   hubot about <slack username>

# Not in use:
#   hubot register email <email>

{ p } = require 'lightsaber'
{ values } = require 'lodash'
UsersController = require '../controllers/users-controller'
swarmbot = require '../models/swarmbot'
User = require '../models/user'
DCO = require '../models/dco'

module.exports = (robot) ->

  # Generic auto register
  robot.respond /\s*/i, (msg) ->
    new UsersController().register(msg)

  # Deprecate register me now that we have auto-registration
  # robot.respond /register me$/i, (msg) ->
  #   new UsersController().register(msg)

  robot.respond /register btc (.+)$/i, (msg) ->
    btcAddress = msg.match[1]
    new UsersController().registerBtc(msg, { btcAddress })

  robot.respond /set community\s+(.+)\s*$/i, (msg) ->
    community = msg.match[1]
    new UsersController().setCommunity(msg, { community })

  robot.respond /unset community\s*$/i, (msg) ->
    new UsersController().unsetCommunity(msg)

  robot.respond /about (.*)\s*$/i, (msg) ->
    slackUsername = msg.match[1]
    if slackUsername == 'me'
      new UsersController().getInfo(msg)
    else
      new UsersController().getInfo(msg, { slackUsername })

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
