debug = require('debug')('app')
{log, p, pjson} = require 'lightsaber'
{ assign, keys, find, indexOf, map, contains, filter } = require 'lodash'
Promise = require 'bluebird'
request = require 'request-promise'
swarmbot = require '../models/swarmbot'
FirebaseModel = require './firebase-model'
Proposal = require '../models/proposal'
User = require '../models/user'
UserCollection = require '../collections/user-collection'
Reward = require '../models/reward'
RewardCollection = require '../collections/reward-collection'
ProposalCollection = require '../collections/proposal-collection'

class DCO extends FirebaseModel
  urlRoot: 'projects'
  INITIAL_PROJECT_COINS: 100000000

  bounties: Promise.promisify (cb)->
    @firebase().child('bounties').once 'value', (snapshot)=>
      bounties = snapshot.val() # should really be an array of Proposal objects.
      cb(null, bounties)

  createProposal: (attributes)->
    @makeProposal(attributes)
    .then (proposal)-> proposal.save()

  makeProposal: (attributes)->
    @fetchIfNeeded().then (dco)->
      if dco.exists()
        proposal = new Proposal attributes,
          parent: dco
          # snapshot: dco.snapshot.child(Proposal::urlRoot).child(attributes.id)
        if proposal.exists()
          Promise.reject(Promise.OperationalError("Award '#{attributes.name}' already exists within #{dco.key()}."))
        else
          proposal
      else
        Promise.reject(Promise.OperationalError("The project '#{dco.key()}' does not exist."))

  makeReward: (attributes)->
    attributes.name ?= new Date().toISOString()
    @fetchIfNeeded().then (dco)->
      if not dco.exists()
        return Promise.reject(Promise.OperationalError("The project '#{dco.key()}' does not exist."))

      reward = new Reward attributes, parent: dco
      if reward.exists()
        Promise.reject(Promise.OperationalError("Reward '#{attributes.name}' already exists within #{dco.key()}."))
      else
        reward

  createReward: (attributes)->
    @makeReward(attributes)
    .then (reward)-> reward.save()

  proposals: ->
    @_proposals ?= new ProposalCollection @snapshot.child('proposals'), parent: @

  rewards: ->
    new RewardCollection @snapshot.child('rewards'), parent: @

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
      colu.issueAsset asset, (error, body)->
        if error
          debug "error in asset creation: #{error.message}"
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

  getAssetInfo: ->
    new Promise (resolve, reject)=>
      uri = "#{swarmbot.coluExplorerUrl()}/api/getassetinfowithtransactions?assetId=#{@get('coluAssetId')}"
      debug uri
      request
        uri: uri
        json: true
      .then (data)=>
        resolve data
      .error (error)=>
        debug error.message
        reject Promise.OperationalError("(Currently not available)")

  allHolders: ->
    @getAssetInfo()
    .then (data)=>
      filter data.holders, (holder)=> holder.address != @get('coluAssetAddress')

module.exports = DCO
