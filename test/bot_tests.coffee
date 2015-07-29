chai = require 'chai'
chai.should()

Helper = require 'hubot-test-helper'
helper = new Helper '../src/bots'

describe 'create bounty', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context 'Reputation', ->
    beforeEach ->
      # @room.user.say 'alice', '@hubot rate Esmerelda 88% on awesomeness'

    it 'should allow users to add and query reputation for other users', ->
      @room.user.say 'alice', '@hubot rate Esmerelda 88% on awesomeness'
      @room.user.say 'alice', '@hubot show reputation of Esmerelda'
      @room.messages[-1..-1].should.deep.equal [
        ['hubot', 'Esmerelda has ratings:\n88% awesomeness (from @alice)']
      ]

  context 'user can create a bounty', ->
    beforeEach ->
      @room.user.say 'alice', '@hubot create save-the-world bounty 100 coins'

    it 'should let the user know that the bounty has been created', ->
      @room.messages.should.deep.equal [
        ['alice', '@hubot create save-the-world bounty 100 coins']
        ['hubot', '`save-the-world` bounty created with 100 coins']
      ]
