{log, p, pjson} = require 'lightsaber'
swarmbot = require '../models/swarmbot'
Bounty = require '../models/bounty'

class DCO

  constructor: ({@dcoRef}) ->

  @createBountyFor: ({dcoKey, bountyName, amount}, cb) ->
    dco = DCO.find dcoKey
    dco.createBounty {bountyName, amount}, cb

  @find: (dcoKey) ->
    dcos = swarmbot.firebase().child('projects')
    new DCO dcoRef: dcos.child(dcoKey)

  createBounty: ({bountyName, amount}, cb) ->
    bounty = @dcoRef.child "bounties/#{bountyName}"
    bounty.set {name: bountyName, amount: amount}, (error) ->
      if error
        cb "error creating bounty :("
      else
        cb null, "bounty created"

  awardBounty: ({bountyName, awardee}, cb) ->
    bounty = @dcoRef.child "bounties/#{bountyName}"
    #colu magic

    assetId = @dcoRef.coluAssetId
    toAddress = 'mypgXJgAAvTZQMZcvMsFA7Q5SYo1Mtyj2b'
    fromAddress = 'mypgXJgAAvTZQMZcvMsFA7Q5SYo1Mtyj2a'
    colu = swarmbot.colu()
    colu.on 'connect', ->

      toAddress = colu.hdwallet.getAddress()
      args =
        from: fromAddress
        to: [
          {
            address: toAddress
            assetId: assetId
            amount: bounty.amount
          }
          ]
      colu.sendAsset args, (err, body) ->
        p "we made it", body
        if err
          return console.error "Error: #{err}"
        console.log 'Body: ', body

    colu.init()
    cb null, "bounty awarded"

  getBounty: ({bountyName}) ->
    bountyRef = @dcoRef.child "bounties/#{bountyName}"
    new Bounty {bountyRef}

  # @robot = null
  #
  # @store: ->
  #   throw new Error('robot is not set up') unless @robot
  #   robot.brain.data.dcos or= {}
  #
  # @defaultName: ->
  #   '__default__'
  #
  # @all: ->
  #   robot.brain = []
  #   for key, dcoData of @store()
  #     continue if key is @defaultName()
  #     robot.brain.push new DCO(dcoData.name, dcoData.size, dcoData.members)
  #   robot.brain
  #
  # @getDefault: (members = [])->
  #   @create(@defaultName(), members) unless @exists @defaultName()
  #   @get @defaultName()
  #
  # @count: ->
  #   Object.keys(@store()).length
  #
  # @get: (name)->
  #   return null unless @exists name
  #   dcoData = @store()[name]
  #   new DCO(dcoData.name, "0", dcoData.members)
  #
  # @getOrDefault: (dcoName)->
  #   if dcoName then @get(dcoName) else @getDefault()
  #
  # @exists: (name)->
  #   name of @store()
  #
  # @create: (name, size, balance)->
  #   return false if @exists name
  #   @store()[name] =
  #     name: name
  #     size: size
  #     balance: balance
  #   new DCO(name, size, members)
  #
  # @updateDCOBalance: (name, change)->
  #   return false if @exists name
  #   oldBalance = (@store()[name] || {}).balance
  #   @store()[name] =
  #     name: name
  #     balance: oldBalance + change
  #   true
  #
  # constructor: (name, size, @members = [])->
  #   @name = name or DCO.defaultName()
  #   @size = size or "0"
  #
  # addMember: (member)->
  #   return false if member in @members
  #   @members.push member
  #   true
  #
  # removeMember: (member)->
  #   return false if member not in @members
  #   index = @members.indexOf(member)
  #   @members.splice(index, 1)
  #   true
  #
  # membersCount: ->
  #   @members.length
  #
  # clear: ->
  #   DCO.store()[@name].members = []
  #   @members = []
  #
  # destroy: ->
  #   delete DCO.store()[@name]
  #
  # isDefault: ->
  #   @name is DCO.defaultName()
  #
  # label: ->
  #   if @isDefault()
  #     'dco'
  #   else
  #     "`#{@name}` dco"

module.exports = DCO
