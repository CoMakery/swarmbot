{log, p, pjson} = require 'lightsaber'
chai = require 'chai'
chaiAsPromised = require("chai-as-promised")
chai.should()
chai.use(chaiAsPromised);
# sinon = require 'sinon'
# Helper = require 'hubot-test-helper'

swarmbot = require '../src/models/swarmbot'
Transaction = require '../src/transaction'

# sinon.stub(swarmbot, 'colu').returns
#   on: ->
#   init: ->
#   sendAsset: ->
#   issueAsset: ->

# call this only after stubbing:
# helper = new Helper '../src/bots'

# process.env.EXPRESS_PORT = 8901  # don't conflict with hubot console port 8080
# process.env.FIREBASE_URL = 'https://dazzle-staging.firebaseio-demo.com/'

nock = require 'nock'
#  = require('nock').back
# nockBack.fixtures = "#{__dirname}/fixtures/"
# nockBack.setMode 'record'

nock.disableNetConnect()  # disable real http requests

describe 'swarmbot', ->
  context 'home', ->
    it "shows help upon request", ->
      msg =
        match: [null, "help"]
      transaction = new Transaction
      transaction.respondTo(msg).should.eventually.match ///
        \*Proposals in Jill Land\*
        1: awesome emoticons
        2: dinner at 5
        3: foo
        4: foobar
        5: Create a proposal
        6: More commands

        To take an action, simply enter the number or letter at the beginning of the line.
      ///
