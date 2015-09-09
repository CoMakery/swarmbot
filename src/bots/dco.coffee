# Description:
#   Create a DCO (from Slack or any Hubut supported channel!)
#
# Dependencies:
#   None
#
# Commands:
#   hubot list dcos
#   hubot list dco <dco pattern>
#   hubot join <dco_name> - join a DCO, usually by agreeing to the statement of intent and paying a membership fee
#   hubot create <number> of asset for <dco name> dco


# Not displayed in help
#   hubot how many dcos - how many DCOs are there?
#   hubot select <dco_name> (you must be the creator)
#   hubot create <dco_name> dco
#   hubot set statement of intent <statement_of_intent>
#   hubot send asset to <user_name>
#   hubot create constitution (creates a fork of the Citizen Code constitution)
#   hubot file dco (dynamically creates an LLC)
#   hubot open for membership for $XYZ - allow users to join membership in your DCO for a set price in USD
#   hubot open for membership for xyzBTC - allow users to join membership in your DCO) for a set price in BTC
#   hubot rate <dco_name> - Tells you how much the DCOs assets are trading at on any given day.
#
# Author:
#   fractastical

{log, p, pjson} = require 'lightsaber'
swarmbot        = require '../models/swarmbot'
Config          = require '../models/config'
ResponseMessage = require './helpers/response_message'
UserNormalizer  = require './helpers/user_normalizer'

module.exports = (robot) ->
  # robot.brain.data.bounties or= {}

  # unless Config.adminList()
  #   robot.logger.warning 'HUBOT_TEAM_ADMIN environment variable not set'

  robot.respond /list dcos$/i, (msg) ->

      dcos = swarmbot.firebase().child('projects')
      MAX_MESSAGES_FOR_SLACK = 10
      dcos.orderByKey()
        .limitToFirst(MAX_MESSAGES_FOR_SLACK)
        .on 'child_added', (snapshot) ->
          msg.send snapshot.key()

  robot.respond /join (\S*) dco?.*/i, (msg) ->
    dcos = swarmbot.firebase().child('projects')
    projectName = msg.match[1]

    dcos.child(projectName + '/project_statement').on 'value', (snapshot) ->
      msg.send 'Do you agree with this statement of intent?'
      msg.send snapshot.val()
      msg.send 'Yes/no?'

 # Not sure, this may work in slack, not sure about
 #  robot.respond /register?.*/i, (msg) ->
 #    robot.reply 'some msg'?

      # myFirebaseRef.child('projects/2050_Music_Collective_1431029372/project_name').on 'value', (snapshot) ->
      #   msg.send snapshot.val()
      #   # Alerts "San Francisco"
      #   return

      #
      # myFirebaseRef.child('projects').on 'value', (snapshot) ->
      #
      #   console.log snapshot.val()

  robot.respond /create (\d+) of asset for (.+)$/i, (msg) ->
    colu = swarmbot.colu()
    msg.match.shift()
    [amount, dcoKey] = msg.match

    asset =
      amount: amount
      metadata:
        'assetName': dcoKey
        'issuer': robot.whose msg
        # 'description': 'Super DCO membership'
    colu.on 'connect', ->
      colu.issueAsset asset, (err, body) ->
        if err
          msg.send "error in asset creation"
          return console.error(err)
        dcos = swarmbot.firebase().child('projects')
        console.log 'AssetId: ', body.assetId
        msg.send 'AssetId: ', body.assetId

        dcos.child(dcoKey).update coluAssetId: body.assetId
        console.log 'Body: ', body
        msg.send body

        return
      return
    colu.init()
    msg.send "asset created"
