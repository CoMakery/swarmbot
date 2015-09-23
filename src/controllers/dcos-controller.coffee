{ p } = require 'lightsaber'
swarmbot        = require '../models/swarmbot'

class DcosController
  list: (msg) ->
    communityNames = []
    swarmbot.firebase().child('projects').orderByKey().once 'value', (communities) ->
      communities.forEach (community) ->
        communityNames.push community.key()
        false # otherwise the loop is cancelled.

      msg.send communityNames.join("\n")

  find: (msg, { dcoKey }) ->
    MAX_MESSAGES_FOR_SLACK = 10
    communities = swarmbot.firebase().child('projects')
    communities.orderByKey()
      .startAt(dcoKey).endAt(dcoKey + "~")
      .limitToFirst(MAX_MESSAGES_FOR_SLACK)
      .on 'child_added', (snapshot) ->
        msg.send snapshot.key()

  join: (msg, { dcoKey }) ->
    communities = swarmbot.firebase().child('projects')
    communities.child(dcoKey + '/project_statement').on 'value', (snapshot) ->
      msg.send 'Do you agree with this statement of intent?'
      msg.send snapshot.val()
      msg.send 'Yes/No?'

    dcoJoinStatus = {stage: 1, dcoKey: dcoKey}
    msg.robot.brain.set "dcoJoinStatus", dcoJoinStatus

  count: (msg) ->
    swarmbot.firebase().child('counters/projects/dco').on 'value', (snapshot) ->
      msg.send snapshot.val()

  create: (msg, { dcoKey }) ->
    owner = msg.robot.whose msg
    dco = DCO.find dcoKey
    swarmbot.firebase().child('projects/' + dcoKey).update({project_name : dcoKey, owner : owner})
    dco.issueAsset { dcoKey, amount: 100000000, owner }
    dcoCreateStatus = {stage: 1, dcoKey: dcoKey}
    robot.brain.set "dcoCreateStatus", dcoCreateStatus
    msg.send "Community created. Please provide a statement of intent starting with 'We'"

  issueAsset: (msg, { dcoKey, amount }) ->
    issuer = msg.robot.whose msg
    dco = DCO.find dcoKey
    dco.issueAsset { dcoKey, amount, issuer }
    msg.send "asset created"

module.exports = DcosController
