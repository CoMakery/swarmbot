{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
chai = require 'chai'
chaiAsPromised = require("chai-as-promised")
chai.should()
chai.use(chaiAsPromised)
global.debug = require('debug')('test')
sinon = require 'sinon'

FirebaseServer = require('firebase-server')
swarmbot = require '../../src/models/swarmbot'

MOCK_FIREBASE_ADDRESS = '127.0.1' # strange host name needed by testing framework
process.env.FIREBASE_URL = "ws://#{MOCK_FIREBASE_ADDRESS}:5000"

sinon.stub(swarmbot, 'colu').returns Promise.resolve
  on: ->
  init: ->
  sendAsset: (x, cb)-> cb(null, {txid: 1234})
  issueAsset: ->

before ->
  @firebaseServer = new FirebaseServer 5000, MOCK_FIREBASE_ADDRESS, {}

beforeEach (done)->
  swarmbot.firebase().remove done

afterEach ->
  @firebaseServer.getValue()
  .then (data)=>  debug "Firebase data: #{pjson data}"

after ->
  @firebaseServer.close()
