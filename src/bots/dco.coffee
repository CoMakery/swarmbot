# Description:
#   Create a DCO (from Slack or any Hubut supported channel!)
#
# Dependencies:
#   None
#
# Commands:
#   hubot list dcos - list all existing DCOs (limit 10)
#   hubot list dcos XYZ - list all existing DCOs that match XYZ
#   hubot how many dcos - how many DCOs are there?
#   hubot select <dco_name> (you must be the creator)
#   hubot create <dco_name> dco
#   hubot set statement of intent <statement_of_intent>
#   hubot issue X of asset - issue X of associated asset.
#   hubot send asset to <user_name>
#   hubot create constitution (creates a fork of the Citizen Code constitution)
#   hubot file dco (dynamically creates an LLC)
#   hubot open for membership for $XYZ - allow users to join membership in your DCO for a set price in USD
#   hubot open for membership for xyzBTC - allow users to join membership in your DCO) for a set price in BTC
#   hubot join <dco_name> - join a DCO, usually by agreeing to the statement of intent and paying a membership fee
#   hubot rate <dco_name> - Tells you how much the DCOs assets are trading at on any given day.
#
# Author:
#   fractastical

Config          = require '../models/config'
Account          = require '../models/account'
Asset          = require '../models/asset'
ResponseMessage = require './helpers/response_message'
UserNormalizer  = require './helpers/user_normalizer'
Colu = require('colu')

privateSeed = 'abcd4986fdac1b3a710892ef6eaa708d619d67100d0514ab996582966f927982'

settings =
  network: 'testnet'
  privateSeed: privateSeed
colu = new Colu(settings)

module.exports = (robot) ->
  robot.DCO.data.bounties or= {}
  Asset.robot = Account.robot = robot

  # unless Config.adminList()
  #   robot.logger.warning 'HUBOT_TEAM_ADMIN environment variable not set'

  ##
  ##   hubot issue X of asset - issue X of associated asset.
  ##
  robot.respond /issue (\S*) of asset?.*/i, (msg) ->

        asset =
          amount: msg.match[1]
          metadata:
            'assetName': 'Super DCO'
            'issuer': msg.message.user.name
            'description': 'Super DCO membership'
        colu.on 'connect', ->
          colu.issueAsset asset, (err, body) ->
            if err
              msg.send "error in asset creation"
              return console.error(err)
            console.log 'Body: ', body
            msg.send body
            msg.send "asset created"

            return
          return
        colu.init()

  ##
  ##   hubot issue X of asset - issue X of associated asset.
  ##
  robot.respond /send (\S*) of asset?.*/i, (msg) ->

    amount = msg.match[1]

    assetId = 'LEuQv9iXrfXAvV8T7BG4ykJeErtF1b28YUjz4'
    fromAddress = 'mypgXJgAAvTZQMZcvMsFA7Q5SYo1Mtyj2a'
    phoneNumber = '+1234567890'
    settings =
      network: 'testnet'
      privateSeed: privateSeed
    colu = new Colu(settings)
    colu.on 'connect', ->
      toAddress = colu.hdwallet.getAddress()
      args =
        from: fromAddress
        to: [
          {
            address: toAddress
            assetId: assetId
            amount: amount
          }
          {
            phoneNumber: phoneNumber
            assetId: assetId
            amount: amount
          }
        ]
        metadata:
          'assetName': 'Mission Impossible 16'
          'issuer': 'Fox Theater'
          'description': 'Movie ticket to see the New Tom Cruise flick again'
          'userData': 'meta': [
            {
              key: 'Item ID'
              value: 2
              type: 'Number'
            }
            {
              key: 'Item Name'
              value: 'Item Name'
              type: 'String'
            }
            {
              key: 'Company'
              value: 'My Company'
              type: 'String'
            }
            {
              key: 'Address'
              value: 'San Francisco, CA'
              type: 'String'
            }
          ]
      colu.sendAsset args, (err, body) ->
        if err
          return console.error(err)
        console.log 'Body: ', body
        return
      return
    colu.init()

    ## hubot join dco
    ##
    robot.respond /create dco/i, (msg) ->

      msg.send "The statement of intent is: "
      msg.send "Do you agree with the DCO statement of intent?"

    ## hubot join dco
    ##
    robot.respond /join dco/i, (msg) ->

      msg.send "The statement of intent is: "
      msg.send "Do you agree with the DCO statement of intent?"
