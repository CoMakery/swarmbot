{log, p, pjson} = require 'lightsaber'
{ values, find } = require 'lodash'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
FirebaseModel = require './firebase-model'
Proposal = require '../models/proposal'
Member = require '../models/member'

{ values, assign, map, indexOf } = require 'lodash'

class DCO extends FirebaseModel
  urlRoot: 'projects'

  @find: (dcoKey) ->
    new DCO id: dcoKey

  bounties: Promise.promisify (cb) ->
    @firebase().child('bounties').once 'value', (snapshot) =>
      bounties = snapshot.val() # should really be an array of Proposal objects.
      cb(null, bounties)

  createProposal: ({ name, amount }) ->
    proposal = new Proposal({id: name, amount: amount}, parent: @)
    proposal.save()

  memberIds: ->
    values @get('member_ids')

  addMember: (user) ->
    userId = user.get('id')
    present = (indexOf(@memberIds(), userId) != -1)

    if present
      false
    else
      @firebase().child('member_ids').push().set(userId)
      # @attributes are now out of sync with firebase. Fetch here?
      user

  issueAsset: ({ amount }, cb) ->
    dcoKey = @get('id')
    issuer = @get('owner')
    colu = swarmbot.colu()
    asset =
      amount: amount
      metadata:
        assetName: dcoKey
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

  awardProposal: ({proposalName, awardeeAddress}, cb) ->

    # p "proposal name", proposalName
    # amountRef = @dcoRef.child "bounties/#{proposalName}/amount"
    proposal = new Proposal({id: proposalName}, parent: @)
    @fetch().then (dco)->
      assetId = dco.get 'coluAssetId'
      fromAddress = dco.get 'coluAssetAddress'
      toAddress = awardeeAddress
      p "awardee", awardeeAddress
      p "asset id", assetId
      proposal.fetch().then (proposal) ->
        amount = proposal.get('amount')
        p "proposal amount", amount
        colu = swarmbot.colu()
        # colu.on 'connect', ->
          #colu.hdwallet.getAddress()
        p args =
          from: [ fromAddress ]
          to: [
            {
              address: toAddress
              assetId: assetId
              amount: amount
            }
            ]
        colu.sendAsset args, (err, body) ->
          p "we made it", body
          if err
            p "err:", err
            return console.error "Error: #{err}"
          console.log 'Body: ', body
            # cb null, "proposal successfully awarded"
        # if colu.needToDiscover
        # colu.init()


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


  getProposal: ({proposalName}) ->
    proposalRef = @dcoRef.child "bounties/#{proposalName}"
    new Proposal {proposalRef}

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

  sendAssetToAddress: ({amount, sendeeAddress}, cb) ->
    @dcoRef.on 'value', (snapshot) ->

        assetId = snapshot.val().coluAssetId
        fromAddress = snapshot.val().coluAssetAddress
        toAddress = sendeeAddress
        # p "awardee", awardeeAddress
        # p "asset id", assetId
        amountRef.on 'value', (snapshot) ->
          amount = snapshot.val()
          # p "proposal amount", amount
          colu = swarmbot.colu()
          # colu.on 'connect', ->
            #colu.hdwallet.getAddress()
          p args =
            from: [ fromAddress ]
            to: [
              {
                address: toAddress
                assetId: assetId
                amount: amount
              }
              ]
          colu.sendAsset args, (err, body) ->
            p "we made it", body
            if err
              p "err:", err
              return console.error "Error: #{err}"
            console.log 'Body: ', body
              # cb null, "proposal successfully awarded"
          # if colu.needToDiscover
          # colu.init()


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
