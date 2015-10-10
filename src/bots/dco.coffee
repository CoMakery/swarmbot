# Description:
#   Create a community
#
# Commands:
#

# Hidden Commands:
#   hubot list communities
#   hubot my communities
#   hubot find community <start of community name>
#   hubot create community <community name>
#   hubot join community <community name>
#   hubot how many communities?
#   hubot list members [of <community name>]

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
    log "MATCH 'list communities' : #{msg.match[0]}"
    new DcosController().list(msg)

  robot.respond /my communities$/i, (msg) ->
    log "MATCH 'my communities' : #{msg.match[0]}"
    new DcosController().listMine(msg)

  robot.respond /list members(?: (?:of|in)\s+(.*)\s*)?$/i, (msg) ->
    log "MATCH 'list members' : #{msg.match[0]}"
    dcoKey = msg.match[1]
    new DcosController().listMembers(msg, { dcoKey })

  robot.respond /find community (\S*)$/i, (msg) ->
    log "MATCH 'find community' : #{msg.match[0]}"
    dcoSearch = msg.match[1]
    new DcosController().find(msg, { dcoSearch })

  robot.respond /join community\s+(.*)$/i, (msg) ->
    log "MATCH 'join community' : #{msg.match[0]}"
    dcoKey = msg.match[1]
    new DcosController().join(msg, { dcoKey })

  robot.respond /how many communities\??$/i, (msg) ->
    log "MATCH 'how many communities?' : #{msg.match[0]}"
    new DcosController().count(msg)

  robot.respond /create community (.+)$/i, (msg) ->
    log "MATCH 'create community' : #{msg.match[0]}"
    dcoKey = msg.match[1]
    new DcosController().create(msg, { dcoKey })

  robot.respond /create (\d+) of asset for (.+)$/i, (msg) ->
    [all, amount, dcoKey] = msg.match
    log "MATCH 'create asset' : #{all}"
    new DcosController().issueAsset(msg, { dcoKey, amount })


  # What to do here? Current method will only work for single user.
  # Ideally, state machine stored on the user instance determines what question is
  # being answered.
  robot.respond /(yes$|no$|we\s+.*\s*)/i, (msg) ->
    log "MATCH 'yes|no|we' : #{msg.match[0]}"
    dcoJoinStatus = robot.brain.get("dcoJoinStatus") or null
    dcoCreateStatus = robot.brain.get("dcoCreateStatus") or null

    if dcoJoinStatus != null
      answer = msg.match[1].toLowerCase()
      console.log "stage: #{dcoJoinStatus.stage}"
      switch dcoJoinStatus.stage
        when 1
          if answer == "yes" || answer == "y"
            log 'YES join'
            new DcosController().joinAgreed(msg, { dcoKey: dcoJoinStatus.dcoKey })

          else if answer == "no" || answer == "n"
            log 'NO join'
            msg.reply "Too bad, maybe next time"

          # dcoJoinStatus = {stage: 0}
          # robot.brain.set "dcoJoinStatus", dcoJoinStatus

    if dcoCreateStatus?

      answer = msg.match[1]
      firstTwoLetters = answer.substring(0,2).toLowerCase()
      currentUser = msg.robot.whose msg

      switch dcoCreateStatus.stage
        when 1
          log 'WE statement'
          if firstTwoLetters == "we" && currentUser == dcoCreateStatus.owner
            swarmbot.firebase().child('projects/' + dcoCreateStatus.dcoKey).update({project_statement : answer})
            dcoCreateStatus = {stage: 0}
            robot.brain.set "dcoCreateStatus", dcoCreateStatus
            msg.send "The new statement of intent is: #{answer}"
