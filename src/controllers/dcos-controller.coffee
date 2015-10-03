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
      return @msg.send "The community '#{dco.get('id')}' does not exist." unless dco.exists()
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
      return @msg.send "The community '#{dco.get('id')}' does not exist." unless dco.exists()
      user = @currentUser()
      if dco.addMember user
        @msg.reply "Great, you've joined the DCO"
        # TODO: Membership coin as well as bounty coin
        # dco.sendAsset { amount: 1, recipient: user }
        user.setDco dco.get('id')
      else
        @msg.reply "You are already a member of #{dco.get('id')}!"

    .error(@_showError)

  count: (msg) ->
    swarmbot.firebase().child('projects').once 'value', (snapshot)=>
      msg.send "There are currently #{snapshot.numChildren()} communities."

  create: (@msg, { dcoKey }) ->
    owner = @currentUser().get('id')
    dco = new DCO(id: dcoKey, owner: owner)
    dco.save()

    @currentUser().setDco dco.get('id')

    dco.issueAsset { amount: 100000000 }
    dcoCreateStatus = {stage: 1, dcoKey: dcoKey, owner: owner}
    @msg.robot.brain.set "dcoCreateStatus", dcoCreateStatus
    @msg.send "Community created. Please provide a statement of intent starting with 'We'"

  issueAsset: (msg, { dcoKey, amount }) ->
    issuer = msg.robot.whose msg
    dco = DCO.find dcoKey
    dco.issueAsset { dcoKey, amount, issuer }
    msg.send "asset created"

module.exports = DcosController
