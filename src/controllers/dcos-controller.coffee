{ p } = require 'lightsaber'
ApplicationController = require './application-controller'
swarmbot = require '../models/swarmbot'
DCO = require '../models/dco'

class DcosController extends ApplicationController
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
    communities.child(dcoKey + '/project_statement').once 'value', (snapshot) ->
      msg.send 'Do you agree with this statement of intent?'
      msg.send snapshot.val()
      msg.send 'Yes/No?'

    dcoJoinStatus = {stage: 1, dcoKey: dcoKey}
    msg.robot.brain.set "dcoJoinStatus", dcoJoinStatus

  joinAgreed: (@msg, { dcoKey }) ->

    #TODO: review, I think this never works/worked on command linde

    user = @currentUser()
    dco = DCO.find dcoKey
    dco.addMember { user }
    # dco.sendAsset { amount: 1, recipient: user }
    user.setDco dcoKey
    @msg.reply "Great, you've joined the DCO"

  count: (msg) ->
    swarmbot.firebase().child('projects').once 'value', (snapshot)=>
      msg.send "There are currently #{snapshot.numChildren()} communities."

  create: (msg, { dcoKey }) ->
    owner = msg.robot.whose msg
    dco = new DCO(id: dcoKey, owner: owner)
    dco.save()

    # swarmbot.firebase().child('projects/' + dcoKey).update({project_name : dcoKey, owner : owner})
    dco.issueAsset { amount: 100000000 }
    dcoCreateStatus = {stage: 1, dcoKey: dcoKey, owner: owner}
    msg.robot.brain.set "dcoCreateStatus", dcoCreateStatus
    msg.send "Community created. Please provide a statement of intent starting with 'We'"

  issueAsset: (msg, { dcoKey, amount }) ->
    issuer = msg.robot.whose msg
    dco = DCO.find dcoKey
    dco.issueAsset { dcoKey, amount, issuer }
    msg.send "asset created"

module.exports = DcosController
