# Description:
#   Create a currency using hubot
#
# Dependencies:
#   None
#
# Commands:
#   hubot create <currecy_name> currency X coins - create currency called <bounty_name> with X coins
#   hubot list currencies - list all existing currencies
#   hubot send X currency <currency_name> to <recipient> - send currency
#
# Author:
#   fractastical

Config          = require './models/config'
Currency            = require './models/currency'
ResponseMessage = require './helpers/response_message'
UserNormalizer  = require './helpers/user_normalizer'

module.exports = (robot) ->
  robot.brain.data.bounties or= {}
  Currency.robot = robot


  ##
  ##   hubot create <currecy_name> currency X coins - create currency called <bounty_name> with X coins
  ##
  robot.respond /create (\S*) currency (\S*) coins?.*/i, (msg) ->

    currencyName = msg.match[1]
    currencyUnits = msg.match[2]
    if currency = Currency.get currencyName
      message = ResponseMessage.bountyAlreadyExists currency
    else
      currency = Currency.create currencyName, currencyUnits
      message = ResponseMessage.bountyCreated currency
    msg.send message

  ##
  ##   hubot send X currency <currency_name> to <recipient> - send currency
  ##
  robot.respond /send (\S*) currency (\S*) coins to (\S*) ?.*/i, (msg) ->

    currencyName = msg.match[1]
    currencySize = msg.match[2]
    currencyRecpient = msg.match[3]

  ##
  ##   hubot list currencies - list all existing currencies
  ##

  robot.respond /list currencies ?.*/i, (msg) ->
    currencies = Currency.all()
    msg.send ResponseMessage.listCurrencies(currencies)
