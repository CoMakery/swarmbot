# Description:
#   Create a DCO (from Slack or any Hubut supported channel!)
#
# Dependencies:
#   None
#
# Commands:
#   hubot list dcos
#   hubot how many dcos?
#   hubot create <dco_name>
#   hubot join <dco_name>
#   hubot create <number> of asset for <dco name>

# Not displayed in help
#   hubot tag <dco_name> <tag>
#   hubot list dco <dco pattern>
#   hubot select <dco_name> (you must be the creator)
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
DCO = require '../models/dco'

module.exports = (robot) ->
  # robot.brain.data.bounties or= {}

  # unless Config.adminList()
  #   robot.logger.warning 'HUBOT_TEAM_ADMIN environment variable not set'

  swarmbot.colu().init()

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




  robot.respond /how many dcos?$/i, (msg) ->
          swarmbot.firebase().child('counters/projects/dco').on 'value', (snapshot) ->
              msg.send snapshot.val()

  robot.respond /create (.+)$/i, (msg) ->
    msg.match.shift()
    [dcoKey] = msg.match
    rando = Math.floor(Math.random()*90000) + 10000

    owner = robot.whose msg
    dco = DCO.find dcoKey

    swarmbot.firebase().child('projects/' + dcoKey).update({project_name : dcoKey, owner : owner})
    dco.issueAsset { dcoKey, amount: 100000000, owner }
    msg.send "asset created"

  robot.respond /create (\d+) of asset for (.+)$/i, (msg) ->
    msg.match.shift()
    [amount, dcoKey] = msg.match

    issuer = robot.whose msg
    dco = DCO.find dcoKey
    dco.issueAsset { dcoKey, amount, issuer }
    msg.send "asset created"
