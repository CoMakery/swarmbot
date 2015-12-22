{ p } = require 'lightsaber'
sinon = require 'sinon'
{ createUser, createProject, message } = require '../helpers/testHelper'
ProjectsStateController = require '../../src/controllers/projects-state-controller'
User = require '../../src/models/user'

describe 'ProjectsStateController', ->
  msg = null
  controller = null
  spy = null

  setup = =>
    App.robot =
      adapter: {}

    App.pmReply = (msg, textOrAttachments)=>
      reply = textOrAttachments.text or textOrAttachments
      msg.parts.push reply

    createUser
      state: "projects#show"
      currentProject: null
    .then (@currentUser)=>
      msg = message('', {@currentUser})
      controller = new ProjectsStateController(msg)
#      spy = sinon.spy(App, 'pmReply')

#  afterEach ->
#    App.pmReply.restore()

  describe '#show', ->
    it "shows an error if project doesn't exist", ->
      setup().then =>
        controller.show()
        .then ->
          msg.parts[0].should.eq 'Couldn\'t find current project'
          msg.currentUser.get('state').should.eq 'projects#index'
#          spy.should.have.been.calledWith("Couldn't find current project")

  describe '#capTable', ->
    it "shows an error if project doesn't exist", ->
      setup().then =>
        controller.show()
        .then ->
          msg.parts[0].should.eq 'Couldn\'t find current project'
          msg.currentUser.get('state').should.eq 'projects#index'
#          spy.should.have.been.calledWith("Couldn't find current project")

  describe '#rewardsList', ->
    it "shows an error if project doesn't exist", ->
      setup().then =>
        controller.show()
        .then ->
          msg.parts[0].should.eq 'Couldn\'t find current project'
          msg.currentUser.get('state').should.eq 'projects#index'
#          spy.should.have.been.calledWith("Couldn't find current project")
