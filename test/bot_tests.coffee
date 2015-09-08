chai = require 'chai'
chai.should()

Helper = require 'hubot-test-helper'
helper = new Helper '../src/bots'

process.env.EXPRESS_PORT = 8901

describe 'create bounty', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context 'user can create an asset for an existing dco', ->
    beforeEach ->
      @room.user.say 'alice', '@hubot create 2000 of asset for save-the-world dco'

    it 'should let the user know that the asset has been created', ->
      @room.messages.should.deep.equal [
        ['alice', '@hubot create 2000 of asset for save-the-world dco']
        ['hubot', 'asset created']
      ]

  # context 'user can create a bounty in the context of a dco ', ->
  #
  # context 'dco admin can award bounty to user', ->


  context 'user can create a bounty', ->
    beforeEach ->
      @room.user.say 'alice', '@hubot create save-the-world bounty 100 coins'

    it 'should let the user know that the bounty has been created', ->
      @room.messages.should.deep.equal [
        ['alice', '@hubot create save-the-world bounty 100 coins']
        ['hubot', '`save-the-world` bounty created with 100 coins']
      ]
