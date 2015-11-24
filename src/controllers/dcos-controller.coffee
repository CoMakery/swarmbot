{ p } = require 'lightsaber'
ApplicationController = require './application-controller'
swarmbot = require '../models/swarmbot'
DCO = require '../models/dco'
DcoCollection = require '../collections/dco-collection'
ZorkHelper = require '../helpers/zork-helper'

class DcosController extends ApplicationController

  listMine: (@msg) ->
    DcoCollection.create().then (allDcos) =>
      myDcos = allDcos.filter((dco) => dco.hasMember @currentUser())
      @msg.send @textList myDcos

  textList: (dcos) ->
    dcoNames = dcos.map (dco) -> dco.key()
    dcoNames.join "\n"

  listMembers: (@msg, { dcoKey }) ->
    @community = dcoKey
    @getDco()
    .then (dco)-> dco.fetch()
    .then (dco)->
      dco.members().fetch().then (members) =>
        messages = members.map (member)=>
          @_userText(member)
        @msg.send(messages.join("\n"))
    .error(@_showError)

  find: (msg, { dcoSearch }) ->
    swarmbot.firebase().child('projects').orderByKey()
      .startAt(dcoSearch).endAt(dcoSearch + "~")
      .once 'value', (dcos) ->
        dcoNames = []
        dcos.forEach (dco) ->
          dcoNames.push dco.key()
          false
        msg.send dcoNames.join("\n")

  join: (@msg, { dcoKey }) ->
    @community = dcoKey
    @getDco()
    .then (dco) -> dco.fetch()
    .then (dco) ->
      return @msg.send "The community '#{dco.key()}' does not exist." unless dco.exists()
      return @msg.send "You are already a member of this community." if dco.hasMember(@currentUser())

      @msg.send [
        'Do you agree with this statement of intent?',
        "#{dco.get('project_statement')}",
        'Yes/No?'
      ].join "\n"

      dcoJoinStatus = {stage: 1, dcoKey: dcoKey}
      @msg.robot.brain.set "dcoJoinStatus", dcoJoinStatus

  joinAgreed: (@msg, { dcoKey }) ->
    @community = dcoKey
    @getDco()
    .then (dco)-> dco.fetch()
    .then (dco)->
      return @msg.send "The community '#{dco.key()}' does not exist." unless dco.exists()
      user = @currentUser()
      if dco.addMember user
        @msg.reply "Great, you've joined the DCO"
        # TODO: Membership coin as well as bounty coin
        # dco.sendAsset { amount: 1, recipient: user }
        user.setDcoTo dco.key()
      else
        @msg.reply "You are already a member of #{dco.key()}!"

    .error(@_showError)

  create: (@msg, { dcoName }) ->
    owner = @currentUser().key()
    DCO.find(dcoName).then (dco) =>
      if dco.exists()
        return @msg.send "Community '#{dcoName}' already exists!"

      dco.set 'project_owner', owner
      dco.save()

      user = @currentUser()
      user.setDcoTo dco.key()
      user.set 'state', 'general#home' # ignore the state machine, go directly to home.
      user.save()

      dco.issueAsset { amount: 100000000 }
      dcoCreateStatus = {stage: 1, dcoName: dcoName, project_owner: owner}
      p "dcoCreateStatus", dcoCreateStatus
      @msg.robot.brain.set "dcoCreateStatus_" + owner, dcoCreateStatus
      @msg.robot.pmReply @msg, [
        ZorkHelper::info "Project created."
        ZorkHelper::question "Please provide a project description starting with 'We'"
      ]

  issueAsset: (msg, { dcoKey, amount }) ->
    issuer = msg.robot.whose msg
    dco = DCO.find dcoKey
    dco.issueAsset { dcoKey, amount, issuer }
    msg.send "asset created"

module.exports = DcosController
