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
      member[userId] = { joined_at: new Date, bounties_claimed: {} }
      @firebase().child('members').update(member)
      # @attributes are now out of sync with firebase. Fetch here?
      user

  issueAsset: ({ amount }, cb) ->
    dcoKey = @get('id')
    issuer = dcoKey
    asset =
      amount: amount
      metadata:
        assetName: dcoKey + ' Coin'
        issuer: issuer
        # 'description': 'Super DCO membership'
    swarmbot.colu().then (colu) =>
      colu.issueAsset asset, (err, body) ->
        if err
          p "error in asset creation"
          return console.error(err)
        dcos = swarmbot.firebase().child('projects')
        console.log 'AssetId: ', body.assetId

        dcos.child(dcoKey).update { coluAssetId: body.assetId, coluAssetAddress: body.issueAddress }

        console.log 'Body: ', body

        return

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

module.exports = DCO
