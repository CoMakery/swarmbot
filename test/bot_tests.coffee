chai = require 'chai'
chai.should()
sinon = require 'sinon'
Helper = require 'hubot-test-helper'
swarmbot = require '../src/models/swarmbot'

sinon.stub(swarmbot, 'colu').returns
  on: ->
  init: ->

# call this only after stubbing:
helper = new Helper '../src/bots'

process.env.EXPRESS_PORT = 8901  # don't conflit with hubot console port 8080
process.env.FIREBASE_URL = 'https://dazzle-staging.firebaseio-demo.com/'

describe 'swarmbot', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach  -> @room.destroy()

  context 'user can create an asset for an existing dco', ->
    it 'should let the user know that the asset has been created', ->
      @room.user.say 'alice', '@hubot create 2000 of asset for save-the-world'
      @room.messages.should.deep.equal [
        ['alice', '@hubot create 2000 of asset for save-the-world']
        ['hubot', 'asset created']
      ]

  # context 'user can create a bounty in the context of a dco', ->
  #   it 'should let the user know that the bounty has been created', ->
  #     @room.user.say 'alice', '@hubot create a plant-a-tree bounty of 30 for save-the-world'
  #     @room.messages.should.deep.equal [
  #       ['alice', '@hubot create plant-a-tree bounty of 30 for save-the-world']
  #       ['hubot', 'bounty created']
  #     ]

  # context 'user can create a bounty', ->
  #   it 'should let the user know that the bounty has been created', ->
  #     @room.user.say 'alice', '@hubot create save-the-world bounty 100 coins'
  #     @room.messages.should.deep.equal [
  #       ['alice', '@hubot create save-the-world bounty 100 coins']
  #       ['hubot', '`save-the-world` bounty created with 100 coins']
  #     ]

  # context 'dco admin can award bounty to user', ->
