{log, p, pjson} = require 'lightsaber'
{ assign, keys, find, indexOf, map, contains } = require 'lodash'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
FirebaseModel = require './firebase-model'
Proposal = require '../models/proposal'
User = require '../models/user'
UserCollection = require '../collections/user-collection'

class DCO extends FirebaseModel
  urlRoot: 'projects'

  bounties: Promise.promisify (cb) ->
    @firebase().child('bounties').once 'value', (snapshot) =>
      bounties = snapshot.val() # should really be an array of Proposal objects.
      cb(null, bounties)

  createProposal: (attributes) ->
    @fetchIfNeeded().then (dco)->
      if dco.exists()
        proposal = new Proposal attributes,
          parent: dco
          snapshot: dco.snapshot.child(Proposal::urlRoot).child(attributes.id)
        if proposal.exists()
          Promise.reject(Promise.OperationalError("Proposal '#{attributes.id}' already exists within #{dco.get('id')}."))
        else
          proposal.save()
      else
        Promise.reject(Promise.OperationalError("The community '#{dco.get('id')}' does not exist."))


  memberIds: ->
    keys @get('members')

  members: ->
    new UserCollection(map @memberIds(), (id) -> new User({id: id}))

  hasMember: (user) ->
    contains @memberIds(), user.get('id')

  addMember: (user) ->
    userId = user.get('id')
    present = (indexOf(@memberIds(), userId) != -1)

    if present
      false
    else
      member = {}
      member[userId] = new Date
      @firebase().child('members').update(member)
      # @attributes are now out of sync with firebase. Fetch here?
      user

  issueAsset: ({ amount }, cb) ->
    dcoKey = @get('id')
    issuer = dcoKey
    colu = swarmbot.colu()
    asset =
      amount: amount
      metadata:
        assetName: dcoKey + ' Coin'
        issuer: issuer
        # 'description': 'Super DCO membership'
    # colu.on 'connect', ->
    colu.issueAsset asset, (err, body) ->
      if err
        p "error in asset creation"
        return console.error(err)
      dcos = swarmbot.firebase().child('projects')
      console.log 'AssetId: ', body.assetId

      dcos.child(dcoKey).update { coluAssetId: body.assetId, coluAssetAddress: body.issueAddress }

      console.log 'Body: ', body

      return

    # @dcoRef.on 'value', (snapshot) ->
    #     assetId = snapshot.val().coluAssetId
    #     fromAddress = snapshot.val().coluAssetAddress
    #     toAddress = awardeeAddress
    #     # p "awardee", awardeeAddress
    #     # p "asset id", assetId
    #     amountRef.on 'value', (snapshot) ->
    #       amount = snapshot.val()
    #       # p "proposal amount", amount
    #       colu = swarmbot.colu()
    #       # colu.on 'connect', ->
    #         #colu.hdwallet.getAddress()
    #       p args =
    #         from: [ fromAddress ]
    #         to: [
    #           {
    #             address: toAddress
    #             assetId: assetId
    #             amount: amount
    #           }
    #           ]
    #       colu.sendAsset args, (err, body) ->
    #         p "we made it", body
    #         if err
    #           p "err:", err
    #           return console.error "Error: #{err}"
    #         console.log 'Body: ', body
    #           # cb null, "proposal successfully awarded"
    #       # if colu.needToDiscover
    #       # colu.init()


  # getProposal: ({proposalName}) ->
  #   proposalRef = @dcoRef.child "bounties/#{proposalName}"
  #   new Proposal {proposalRef}

  sendAsset: ({amount, recipient}, cb) ->
    p "username", recipient.get('id')
    recipient.fetch().then (user) ->
      recipientAddress = user.get('btc_address')
      if recipientAddress?
        p "address", recipientAddress
        # TODO: Doesn't work, awaiting feedback from @harlan
        # @sendAssetToAddress amount, sendeeAddress
      else
        cb "user must register before receiving assets"

  # sendAssetToAddress: ({amount, sendeeAddress}, cb) ->
  #   @dcoRef.on 'value', (snapshot) ->
  #
  #       assetId = snapshot.val().coluAssetId
  #       fromAddress = snapshot.val().coluAssetAddress
  #       toAddress = sendeeAddress
  #       # p "awardee", awardeeAddress
  #       # p "asset id", assetId
  #       amountRef.on 'value', (snapshot) ->
  #         amount = snapshot.val()
  #         # p "proposal amount", amount
  #         colu = swarmbot.colu()
  #         # colu.on 'connect', ->
  #           #colu.hdwallet.getAddress()
  #         p args =
  #           from: [ fromAddress ]
  #           to: [
  #             {
  #               address: toAddress
  #               assetId: assetId
  #               amount: amount
  #             }
  #             ]
  #         colu.sendAsset args, (err, body) ->
  #           p "we made it", body
  #           if err
  #             p "err:", err
  #             return console.error "Error: #{err}"
  #           console.log 'Body: ', body
  #             # cb null, "proposal successfully awarded"
  #         # if colu.needToDiscover
  #         # colu.init()

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

module.exports = DCO
