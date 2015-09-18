# Description:
#   User / account managemnet
#
# Commands:
#   hubot register me
#   hubot register btc <btc_address>
#   hubot set community <preferred community>

# Not in use:
#   hubot register email <email>

{ p } = require 'lightsaber'
{ values } = require 'lodash'
UsersController = require '../controllers/users-controller'
swarmbot = require '../models/swarmbot'
Bounty = require '../models/bounty'
User = require '../models/user'
DCO = require '../models/dco'

module.exports = (robot) ->

  robot.respond /register me$/i, (msg) ->
    new UsersController().register(msg)

  robot.respond /register btc (.+)$/i, (msg) ->
    btcAddress = msg.match[1]
    new UsersController().registerBtc(msg, { btcAddress })

  robot.respond /set community (.+)$/i, (msg) ->
    community = msg.match[1]
    new UsersController().setCommunity(msg, { community })

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
