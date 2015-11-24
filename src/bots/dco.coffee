# Commands:
#   hubot create project <project name>
#

{log, p, pjson} = require 'lightsaber'
DcosController = require '../controllers/dcos-controller'
swarmbot        = require '../models/swarmbot'
ZorkHelper = require '../helpers/zork-helper'
DCO = require '../models/dco'

module.exports = (robot) ->
  App.respond /my communities$/i, (msg) ->
    log "MATCH 'my communities' : #{msg.match[0]}"
    new DcosController().listMine(msg)

  App.respond /list members(?: (?:of|in)\s+(.*)\s*)?$/i, (msg) ->
    log "MATCH 'list members' : #{msg.match[0]}"
    dcoKey = msg.match[1]
    new DcosController().listMembers(msg, { dcoKey })

  App.respond /find community (\S*)$/i, (msg) ->
    log "MATCH 'find community' : #{msg.match[0]}"
    dcoSearch = msg.match[1]
    new DcosController().find(msg, { dcoSearch })

  App.respond /join\s+(.*)$/i, (msg) ->
    log "MATCH 'join' : #{msg.match[0]}"
    dcoKey = msg.match[1]
    new DcosController().join(msg, { dcoKey })

  App.respond /create project (.+)$/i, (msg) ->
    log "MATCH 'create project' : #{msg.match[0]}"
    dcoName = msg.match[1]
    new DcosController().create(msg, { dcoName })

  App.respond /dao me (.+)$/i, (msg) ->
    log "MATCH 'dao me' : #{msg.match[0]}"
    dcoKey = msg.match[1]
    new DcosController().create(msg, { dcoKey })

  App.respond /create (\d+) of asset for (.+)$/i, (msg) ->
    [all, amount, dcoKey] = msg.match
    log "MATCH 'create asset' : #{all}"
    new DcosController().issueAsset(msg, { dcoKey, amount })


  # What to do here? Current method will only work for single user.
  # Ideally, state machine stored on the user instance determines what question is
  # being answered.
  #
  # NOTE that here we use robot.respond to allow other actions to execute,
  # even when this matches:
  robot.respond /(yes$|no$|we\s+.*\s*)/i, (msg) ->
    log "MATCH 'yes|no|we' : #{msg.match[0]}"
    currentUser = msg.robot.whose msg

    dcoJoinStatus = robot.brain.get("dcoJoinStatus") or null
    dcoCreateStatus = robot.brain.get("dcoCreateStatus_" + currentUser) or null

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

      switch dcoCreateStatus.stage
        when 1
          log 'WE statement'
          if firstTwoLetters == "we" && currentUser == dcoCreateStatus.project_owner
            dco = new DCO name: dcoCreateStatus.dcoName
            dco.set 'project_statement', answer
            dco.save()
            dcoCreateStatus = {stage: 0}
            key = "dcoCreateStatus_" + currentUser
            robot.brain.set key, dcoCreateStatus
            msg.robot.pmReply msg, ZorkHelper::info "The new project description is: #{answer}"
