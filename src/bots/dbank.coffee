# Description:
#   Create a bank using hubot
#
# Dependencies:
#   None
#
# Commands:
#   hubot create <currecy_name> bank X coins - create bank called <bounty_name> with X coins
#   hubot list currencies - list all existing currencies
#   hubot send X bank <bank_name> to <recipient> - send bank
#
# Author:
#   fractastical

Config          = require '../models/config'
DBank            = require '../models/dbank'
ResponseMessage = require './helpers/response_message'
UserNormalizer  = require './helpers/user_normalizer'

module.exports = (robot) ->
  robot.brain.data.bounties or= {}
  DBank.robot = robot

  ##
  ##   hubot create <currecy_name> bank X coins - create bank called <bounty_name> with X coins
  ##
  robot.respond /create (\S*) bank?.*/i, (msg) ->

    bankName = msg.match[1]
    bankUnits = msg.match[2]
    if bank = DBank.get bankName
      message = ResponseMessage.bountyAlreadyExists bank
    else
      bank = DBank.create bankName, bankUnits
      message = ResponseMessage.bountyCreated bank
    msg.send message

  ##
  ##   hubot desposit X coins to <bank_name>  - send bank
  ##
  robot.respond /deposit (\S*) coins to (\S*) bank ?.*/i, (msg) ->

    coinAmount = msg.match[1]
    bankName = msg.match[2]

  ##
  ##   hubot desposit X coins to <bank_name>  - send bank
  ##
  robot.respond /withdraw (\S*) coins from (\S*) bank ?.*/i, (msg) ->

    coinAmount = msg.match[1]
    bankName = msg.match[2]


  ##
  ##   hubot list banks - list all existing banks
  ##

  robot.respond /list banks ?.*/i, (msg) ->
    banks = DBank.all()
    msg.send ResponseMessage.listCurrencies(banks)
