{log, p, pjson} = require 'lightsaber'
chai = require 'chai'
chai.should()
sinon = require 'sinon'
# nock = require 'nock'
Helper = require 'hubot-test-helper'

swarmbot = require '../src/models/swarmbot'
DCO = require '../src/models/dco'

sinon.stub(swarmbot, 'colu').returns
  on: ->
  init: ->

# sinon.stub(swarmbot, 'firebase')

# call this only after stubbing:
helper = new Helper '../src/bots'

process.env.EXPRESS_PORT = 8901  # don't conflit with hubot console port 8080
process.env.FIREBASE_URL = 'https://dazzle-staging.firebaseio-demo.com/'

describe 'swarmbot', ->

  beforeEach -> @room = helper.createRoom()
  afterEach -> @room.destroy()

  context 'DCO asset', ->
    it 'user can create an asset for an existing dco', ->
      @room.user.say 'alice', '@hubot create 2000 of asset for save-the-world'
      @room.messages.should.deep.equal [
        ['alice', '@hubot create 2000 of asset for save-the-world']
        ['hubot', 'asset created']
      ]
      # check that the asset exists -- in fb/colu

  context 'DCO bounty', ->
    it 'a DCO can create a bounty', (done) ->
      bounty =
        dcoKey: 'save-the-world'
        bountyName: 'plant a tree'
        amount: 999
      DCO.createBountyFor bounty, (error, message) ->
        message.should.equal 'bounty created'
        done()

  # context 'user can create a bounty', ->
  #   it 'should let the user know that the bounty has been created', ->
  #     @room.user.say 'alice', '@hubot create save-the-world bounty 100 coins'
  #     @room.messages.should.deep.equal [
  #       ['alice', '@hubot create save-the-world bounty 100 coins']
  #       ['hubot', '`save-the-world` bounty created with 100 coins']
  #     ]

  # context 'dco admin can award bounty to user', ->
