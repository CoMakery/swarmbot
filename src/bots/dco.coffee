# Description:
#   Create a community
#
# Commands:
#   hubot list communities
#   hubot find community <start of community name>
#   hubot create community <community name>
#   hubot join community <community name>
#   hubot community <community name> list bounties
#   hubot how many communities?

# Available but not displayed in help
#   hubot create <number> of asset for <community name>

# DCO Interface Ideas
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
ResponseMessage = require './helpers/response_message'
UserNormalizer  = require './helpers/user_normalizer'
DcosController = require '../controllers/dcos-controller'
swarmbot        = require '../models/swarmbot'
DCO = require '../models/dco'

module.exports = (robot) ->
  robot.respond /list communities$/i, (msg) ->
    new DcosController().list(msg)

  robot.respond /find community (\S*)$/i, (msg) ->
    dcoSearch = msg.match[1]
    new DcosController().find(msg, { dcoSearch })

  robot.respond /join community (\S*)$/i, (msg) ->
    dcoKey = msg.match[1]
    new DcosController().join(msg, { dcoKey })

  robot.respond /how many communities\?$/i, (msg) ->
    new DcosController().count(msg)

  robot.respond /create community (.+)$/i, (msg) ->
    dcoKey = msg.match[1]
    new DcosController().create(msg, { dcoKey })

  robot.respond /create (\d+) of asset for (.+)$/i, (msg) ->
    [all, amount, dcoKey] = msg.match
    new DcosController().issueAsset(msg, { dcoKey, amount })

  # What to do here? Current method will only work for single user.
  # Ideally, state machine stored on the user instance determines what question is
  # being answered.
  robot.respond /(yes$|no$|we\s+.*\s*)/i, (msg) ->
    p msg.match[1]
    dcoJoinStatus = robot.brain.get("dcoJoinStatus") or null
    dcoCreateStatus = robot.brain.get("dcoCreateStatus") or null

    if dcoJoinStatus != null
      answer = msg.match[1].toLowerCase()
      console.log "stage: #{dcoJoinStatus.stage}"
      switch dcoJoinStatus.stage
        when 1
          if answer == "yes" || answer == "y"
            new DcosController().joinAgreed(msg, { dcoKey: dcoJoinStatus.dcoKey })

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
            msg.send "The statement of intent is: #{answer}"
