debug = require('debug')('app')
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
  INITIAL_PROJECT_COINS: 100000000

  bounties: Promise.promisify (cb)->
    @firebase().child('bounties').once 'value', (snapshot)=>
      bounties = snapshot.val() # should really be an array of Proposal objects.
      cb(null, bounties)

  createProposal: (attributes)->
    @makeProposal(attributes).then (proposal)-> proposal.save()

  makeProposal: (attributes)->
    @fetchIfNeeded().then (dco)->
      if dco.exists()
        proposal = new Proposal attributes,
          parent: dco
          # snapshot: dco.snapshot.child(Proposal::urlRoot).child(attributes.id)
        if proposal.exists()
          Promise.reject(Promise.OperationalError("Task '#{attributes.name}' already exists within #{dco.key()}."))
        else
          proposal
      else
        Promise.reject(Promise.OperationalError("The project '#{dco.key()}' does not exist."))

  memberIds: ->
    keys @get('members')

  members: ->
    new UserCollection(map @memberIds(), (key)-> new User({name: key}))

  hasMember: (user)->
    contains @memberIds(), user.key()

  addMember: (user)->
    userId = user.key()
    present = (indexOf(@memberIds(), userId) != -1)

    if present
      false
    else
      member = {}
      member[userId] = { joined_at: new Date, bounties_claimed: {} }
      @firebase().child('members').update(member)
      # @attributes are now out of sync with firebase. Fetch here?
      user

  issueAsset: ({ amount }, cb)->
    dcoKey = @key()
    issuer = dcoKey
    asset =
      amount: amount
      metadata:
        assetName: dcoKey + ' Coin'
        issuer: issuer

    swarmbot.colu()
    .then (colu)=>
      colu.issueAsset asset, (err, body)->
        if err
          debug "error in asset creation: #{err}"
        else
          dcos = swarmbot.firebase().child('projects')
          debug "AssetId: #{body.assetId}"
          debug "Full response: #{pjson body}"
          dcos.child(dcoKey).update { coluAssetId: body.assetId, coluAssetAddress: body.issueAddress }

  sendAsset: ({amount, recipient}, cb)->
    p "username", recipient.key()
    recipient.fetch().then (user)->
      recipientAddress = user.get('btc_address')
      if recipientAddress?
        debug "creating project; address: #{recipientAddress}",
      else
        cb "user must register before receiving assets"

module.exports = DCO
