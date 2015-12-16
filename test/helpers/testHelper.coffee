{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
chai = require 'chai'
chaiAsPromised = require("chai-as-promised")
chai.should()
chai.use(chaiAsPromised)
global.debug = require('debug')('test')
sinon = require 'sinon'
{ defaults } = require 'lodash'

Project = require '../../src/models/project'
User = require '../../src/models/user'

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

class TestHelper
  @createUser: (args = {})=>
    {userId, projectId} = defaults args, {userId: "some user id", projectId: "some project id"}
    new User
      name: userId
      current_project: projectId
      state: 'projects#show'
      btc_address: '3HNSiAq7wFDaPsYDcUxNSRMD78qVcYKicw'
    .save()

  @createProject: (args = {})=>
    {userId, projectId} = defaults args, {userId: "some user id", projectId: "some project id"}
    @project = new Project
      name: projectId
      project_owner: userId
      tasksUrl: 'http://example.com'
    @project.save()

module.exports = TestHelper