chai = require 'chai'
chai.should()

Helper = require 'hubot-test-helper'
helper = new Helper '../scripts'

describe 'create bounty', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context 'user can create a bounty', ->
    beforeEach ->
      @room.user.say 'alice', '@hubot create save-the-world bounty 100 coins'

    it 'should let the user know that the bounty has been created', ->
      @room.messages.should.deep.equal [
        ['alice', '@hubot create save-the-world bounty 100 coins']
        ['hubot', '`save-the-world` bounty created with 100 coins']
      ]
