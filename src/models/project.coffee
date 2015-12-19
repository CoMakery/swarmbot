debug = require('debug')('app')
{log, p, pjson} = require 'lightsaber'
{ assign, keys, find, indexOf, map, contains, filter } = require 'lodash'
Promise = require 'bluebird'
request = require 'request-promise'
swarmbot = require '../models/swarmbot'
FirebaseModel = require './firebase-model'
RewardType = require '../models/reward-type'
User = require '../models/user'
UserCollection = require '../collections/user-collection'
Reward = require '../models/reward'
RewardCollection = require '../collections/reward-collection'
RewardTypeCollection = require '../collections/reward-type-collection'

class Project extends FirebaseModel
  urlRoot: 'projects'
  INITIAL_PROJECT_COINS: 100000000

  bounties: Promise.promisify (cb)->
    @firebase().child('bounties').once 'value', (snapshot)=>
      bounties = snapshot.val() # should really be an array of RewardType objects.
      cb(null, bounties)

  createRewardType: (attributes)->
    @makeRewardType(attributes)
    .then (rewardType)-> rewardType.save()

  makeRewardType: (attributes)->
    @fetchIfNeeded().then (project)->
      if project.exists()
        rewardType = new RewardType attributes,
          parent: project
          # snapshot: project.snapshot.child(RewardType::urlRoot).child(attributes.id)
        if rewardType.exists()
          Promise.reject(Promise.OperationalError("Award '#{attributes.name}' already exists within #{project.key()}."))
        else
          rewardType
      else
        Promise.reject(Promise.OperationalError("The project '#{project.key()}' does not exist."))

  makeReward: (attributes)->
    throw new Error "reward attrs should not contain 'name' key" if attributes.name?
    attributes.name = (new Date).toISOString()
    @fetchIfNeeded().then (project)->
      if not project.exists()
        return Promise.reject(Promise.OperationalError("The project '#{project.key()}' does not exist."))

      reward = new Reward attributes, parent: project
      if reward.exists()
        Promise.reject(Promise.OperationalError("Reward '#{attributes.name}' already exists within #{project.key()}."))
      else
        reward

  createReward: (attributes)->
    @makeReward(attributes)
    .then (reward)-> reward.save()

  rewardTypes: ->
    if @snapshot?
      new RewardTypeCollection @snapshot.child(RewardType::urlRoot), parent: @
    else
      new RewardTypeCollection [], parent: @

  rewards: ->
    new RewardCollection @snapshot.child(Reward::urlRoot), parent: @

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
    projectKey = @key()
    issuer = projectKey
    asset =
      amount: amount
      metadata:
        assetName: projectKey + ' Coin'
        issuer: issuer

    swarmbot.colu()
    .then (colu)=>
      colu.issueAsset asset, (error, body)->
        if error
          debug "error in asset creation: #{error.message}"
        else
          projects = swarmbot.firebase().child('projects')
          debug "AssetId: #{body.assetId}"
          debug "Full response: #{pjson body}"
          projects.child(projectKey).update { coluAssetId: body.assetId, coluAssetAddress: body.issueAddress }

  sendAsset: ({amount, recipient}, cb)->
    recipient.fetch().then (user)->
      recipientAddress = user.get('btcAddress')
      if recipientAddress?
        debug "creating project; address: #{recipientAddress}",
      else
        cb "user must register before receiving assets"

module.exports = Project
