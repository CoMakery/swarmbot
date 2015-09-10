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

    p "bounty name", bountyName
    amountRef = @dcoRef.child "bounties/#{bountyName}/amount"
    toAddress = 'mypgXJgAAvTZQMZcvMsFA7Q5SYo1Mtyj2b'
    #for asset LEP4Zu6sdg1rU9T6oXCWDFyWYGVftZRphfjps
    # fromAddress = 'mtC2DpYP3gVZSgbnrmLcEbFt46955oz3hy'

    @dcoRef.on 'value', (snapshot) ->

        assetId = snapshot.val().coluAssetId
        fromAddress = snapshot.val().coluAssetAddress

        # assetId = snapshot.val()
        p "asset id", assetId
        amountRef.on 'value', (snapshot) ->
          amount = snapshot.val()
          p "bounty amount", amount
          colu = swarmbot.colu()
          p "001"
          # colu.on 'connect', ->
            #colu.hdwallet.getAddress()
          p 11
          toAddress = 'n1Kf9tSxasybAcckMNzanzut36vKK1xJ9c'
          p args =
            from: [ fromAddress ]
            to: [
              {
                address: toAddress
                assetId: assetId
                amount: 22
              }
              ]
          colu.sendAsset args, (err, body) ->
            p "we made it", body
            if err
              p "err:", err
              return console.error "Error: #{err}"
            console.log 'Body: ', body
              # cb null, "bounty successfully awarded"
          # if colu.needToDiscover
          # colu.init()


  getBounty: ({bountyName}) ->
    bountyRef = @dcoRef.child "bounties/#{bountyName}"
    new Bounty {bountyRef}


  # pledge: ({email, name}) ->
  #
	# 	# Store new pledge data
	# 	ref = $firebase(new Firebase(firebaseUrl+'/pledges/'))
	# 	ref.$push(pledgeData)
  #
	# 	# Create new user
	# 	.then (storedPledgeData)->
	# 		passphrase = User.generatePassphrase(6)
	# 		encodedPassphrase = User.encodePassword passphrase
	# 		userData =
	# 			first_name: pledgeData.firstName
	# 			last_name: pledgeData.lastName
	# 			email: pledgeData.email
	# 			organization: pledgeData.organization
	# 			temporaryPassword: encodedPassphrase
	# 			signupRequired: true
	# 		User.create pledgeData.email, passphrase, userData
	# 		.then (userData)->
	# 			# Send user email with one-time password
	# 			userCreatedNotification(passphrase)
	# 			# Once user is created send email notification with pledge data to User
	# 			pledgeToUserNotification()
	# 			# Once user is created send email notification with pledge data to Admin
	# 			pledgeToAdminNotification(storedPledgeData)
	# 			# Send Swarm dividend to user
	# 			User.getSwarmDividend(userData.uid)
	# 			# Resolve or reject user create promise
	# 			createUserDefer.resolve()
	# 		.then null, (reason)->
	# 			if reason.code == 'EMAIL_TAKEN'
	# 				pledgeToUserNotification()
	# 				pledgeToAdminNotification(storedPledgeData)
	# 				User.getUidByEmail(pledgeData.email)
	# 				.then (uid)->
	# 					User.getSwarmDividend(uid)
	# 					notifyUserCreatedDefer.resolve()
	# 				createUserDefer.resolve()
	# 			else
	# 				createUserDefer.reject reason


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
