# Description:
#   Create a community
#
# Commands:
#   hubot list communities
#   hubot create community <community name>
#   hubot join community <community name>

# Available but not displayed in help
#   hubot create <number> of asset for <community name>

# Not in use:
#   hubot how many communities?
#   hubot tag <dco_name> <tag>
#   hubot list dco <dco pattern>
#   hubot select <dco_name> (you must be the creator)
#   hubot set statement of intent <statement_of_intent>
#   hubot send asset to <user_name>
#   hubot create constitution (creates a fork of the Citizen Code constitution)
#   hubot file dco (dynamically creates an LLC)
#   hubot open for membership for $XYZ - allow users to join membership in your DCO for a set price in USD
#   hubot open for membership for xyzBTC - allow users to join membership in your DCO) for a set price in BTC
#   hubot rate <dco_name> - Tells you how much the community's assets are trading at on any given day.

{log, p, pjson} = require 'lightsaber'
swarmbot        = require '../models/swarmbot'
ResponseMessage = require './helpers/response_message'
UserNormalizer  = require './helpers/user_normalizer'
DCO = require '../models/dco'

module.exports = (robot) ->

  robot.respond /list communities$/i, (msg) ->
    communities = swarmbot.firebase().child('projects')
    MAX_MESSAGES_FOR_SLACK = 10
    communities.orderByKey()
      .limitToFirst(MAX_MESSAGES_FOR_SLACK)
      .on 'child_added', (snapshot) ->
        msg.send snapshot.key()

  robot.respond /find community (\S*)$/i, (msg) ->
    communities = swarmbot.firebase().child('projects')
    dcoKey = msg.match[1]
    MAX_MESSAGES_FOR_SLACK = 10
    communities.orderByKey()
      .startAt(dcoKey).endAt(dcoKey + "~")
      .limitToFirst(MAX_MESSAGES_FOR_SLACK)
      .on 'child_added', (snapshot) ->
        msg.send snapshot.key()

  robot.respond /join community (\S*)$/i, (msg) ->
    communities = swarmbot.firebase().child('projects')
    dcoKey = msg.match[1]

    communities.child(dcoKey + '/project_statement').on 'value', (snapshot) ->
      msg.send 'Do you agree with this statement of intent?'
      msg.send snapshot.val()
      msg.send 'Yes/No?'

    dcoJoinStatus = {stage: 1, dcoKey: dcoKey}
    robot.brain.set "dcoJoinStatus", dcoJoinStatus

  robot.respond /(yes$|no$|we )/i, (msg) ->
    p msg.match[0]
    dcoJoinStatus = robot.brain.get("dcoJoinStatus") or null
    dcoCreateStatus = robot.brain.get("dcoCreateStatus") or null

    if dcoJoinStatus != null
      answer = msg.match[1].toLowerCase()
      console.log "stage: #{dcoJoinStatus.stage}"
      switch dcoJoinStatus.stage
        when 1
          if answer == "yes" || answer == "y"
            msg.reply "Great, you've joined the DCO"
            dco = DCO.find dcoJoinStatus.dcoKey
            user = robot.whose msg
            dco.sendAsset { amount: 1, sendeeUsername: user }
            # Set to default/preferred community
            userRef = swarmbot.firebase().child('users/' + user)
            userRef.update({ preferred_community : dcoJoinStatus.dcoKey })

          else if answer == "no" || answer == "n"
            msg.reply "Too bad, maybe next time"

          # dcoJoinStatus = {stage: 0}
          # robot.brain.set "dcoJoinStatus", dcoJoinStatus

    if dcoCreateStatus != null

      answer = msg.match[1]
      firstTwoLetters = answer.substring(0,2).toLowerCase()
      switch dcoCreateStatus.stage
        when 1
          if firstTwoLetters == "we"
            swarmbot.firebase().child('projects/' + dcoCreateStatus.dcoKey).update({project_statement : answer})
            dcoCreateStatus = {stage: 0}
            robot.brain.set "dcoCreateStatus", dcoCreateStatus
            msg.send "Statement of intent set"

  robot.respond /how many communities\?$/i, (msg) ->
    swarmbot.firebase().child('counters/projects/dco').on 'value', (snapshot) ->
      msg.send snapshot.val()

  robot.respond /what data\?$/i, (msg) ->
        prettyMessage = pjson msg
        msg.send " yo" + prettyMessage

  robot.respond /create community (.+)$/i, (msg) ->
    msg.match.shift()
    [dcoKey] = msg.match
    owner = robot.whose msg
    dco = DCO.find dcoKey
    swarmbot.firebase().child('projects/' + dcoKey).update({project_name : dcoKey, owner : owner})
    dco.issueAsset { dcoKey, amount: 100000000, owner }
    dcoCreateStatus = {stage: 1, dcoKey: dcoKey}
    robot.brain.set "dcoCreateStatus", dcoCreateStatus
    msg.send "Community created. Please provide a statement of intent starting with 'We'"

  robot.respond /create (\d+) of asset for (.+)$/i, (msg) ->
    msg.match.shift()
    [amount, dcoKey] = msg.match
    issuer = robot.whose msg
    dco = DCO.find dcoKey
    dco.issueAsset { dcoKey, amount, issuer }
    msg.send "asset created"
