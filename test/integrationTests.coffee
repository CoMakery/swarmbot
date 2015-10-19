{log, p, pjson} = require 'lightsaber'
chai = require 'chai'
chaiAsPromised = require("chai-as-promised")
chai.should()
chai.use(chaiAsPromised);

App = require '../src/app'
DCO = require '../src/models/dco'

nock = require 'nock'
#  = require('nock').back
# nockBack.fixtures = "#{__dirname}/fixtures/"
# nockBack.setMode 'record'
# nock.disableNetConnect()  # disable real http requests

mockery = require('mockery')
originalWebsocket = require('faye-websocket')
_ = require('lodash')

Firebase = require 'firebase'
FirebaseServer = require('firebase-server')


# process.env.EXPRESS_PORT = 8901  # don't conflict with hubot console port 8080
process.env.FIREBASE_URL = 'ws://127.0.1:5000'

describe 'swarmbot', ->
  before ->
    @firebaseServer = new FirebaseServer 5000, '127.0.1'

  after ->
    console.log @firebaseServer.getData()
    @firebaseServer.close()

  context 'home', ->

    it "shows no proposals for the default dco", ->
      userId = "slack:1234"
      # @user = new User(id: userId).save()
      # @dco = new DCO(id: "Test DCO").save()
      msg =
        match: [null, "help"]
        robot:
          whose: (msg) -> userId

      reply = App.route(msg)
      reply.should.eventually.match /\*No proposals in swarmbot-lovers\*/
      reply.should.eventually.match /1: Create a proposal/
      reply.should.eventually.match /2: More commands/
