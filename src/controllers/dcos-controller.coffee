{ p } = require 'lightsaber'
swarmbot        = require '../models/swarmbot'

class DcosController
  list: (msg) ->
    swarmbot.firebase().child('projects').orderByKey().once 'value', (dcos) ->
      dcoNames = []
      dcos.forEach (dco) ->
        dcoNames.push dco.key()
        false # otherwise the loop is cancelled.

      msg.send dcoNames.join("\n")

  find: (msg, { dcoSearch }) ->
    swarmbot.firebase().child('projects').orderByKey()
      .startAt(dcoSearch).endAt(dcoSearch + "~")
      .once 'value', (dcos) ->
        dcoNames = []
        dcos.forEach (dco) ->
          dcoNames.push dco.key()
          false

        msg.send dcoNames.join("\n")

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
