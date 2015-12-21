{ defaults, any } = require 'lodash'
{json, log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
global.debug = require('debug')('test')

chai = require 'chai'
chaiAsPromised = require("chai-as-promised")
chai.should()
chai.use(chaiAsPromised)
sinon = require 'sinon'
FirebaseServer = require('firebase-server')
Mitm = require("mitm")

ColuInfo = require '../../src/services/colu-info'
Project = require '../../src/models/project'
User = require '../../src/models/user'
swarmbot = require '../../src/models/swarmbot'

MOCK_FIREBASE_ADDRESS = '127.0.1' # strange host name needed by testing framework
process.env.FIREBASE_URL = "ws://#{MOCK_FIREBASE_ADDRESS}:5000"

ALLOWED_HOSTS = [
  {
    port: 443
    host: "fakeserver.firebaseio.test"
  }
  {
    port: 5000
    host: "127.0.1"
  }
]

sinon.stub(swarmbot, 'colu').returns Promise.resolve
  on: ->
  init: ->
  sendAsset: (x, cb)-> cb(null, {txid: 1234})
  issueAsset: ->

sinon.stub(ColuInfo.prototype, 'getAssetInfo').returns Promise.resolve []
sinon.stub(ColuInfo.prototype, 'balances').returns Promise.resolve [
  {
    name: 'FinTechHacks'
    assetId: 'xyz123'
    balance: 456
  }
]

before ->
  @firebaseServer = new FirebaseServer 5000, MOCK_FIREBASE_ADDRESS,

beforeEach (done)->
  @mitm = Mitm()
  @mitm.on "connect", (socket, opts)->
    allowed = any ALLOWED_HOSTS, (allowedHost)->
      allowedHost.host is opts.host and allowedHost.port is Number(opts.port)
    if allowed
      socket.bypass()
    else
      throw new Error """Call to external service from test suite!
        #{ json host: opts.host, port: opts.port }"""

  swarmbot.firebase().remove done

afterEach ->
  @mitm.disable()
  @firebaseServer.getValue()
  .then (data)=>  debug "Firebase data: #{pjson data}"

after ->
  @firebaseServer.close()

class TestHelper
  @USER_ID = "slack:1234"

  @createUser: (args = {})=>
    defaults args, {
      name: "some user id"
      currentProject: "some project id"
      state: 'projects#show'
      stateData: {}
      btcAddress: '3HNSiAq7wFDaPsYDcUxNSRMD78qVcYKicw'
    }
    new User(args).save()

  @createProject: (args = {})=>
    defaults args, {
      projectOwner: "some user id"
      name: "some project id"
      tasksUrl: 'http://example.com'
    }
    new Project(args).save()

  @createRewardType: (project, args = {})=>
    defaults args, {
      name: 'random reward'
      suggestedAmount: '888'
    }
    project.createRewardType args

  @message = (input, props={})->
    @parts = []
    defaults props, {
      parts: @parts
      match: [null, input]
      send: (reply)=> throw new Error "deprecated, use pmReply"
      message:
        user: {}
      robot: App.robot
    }


module.exports = TestHelper
