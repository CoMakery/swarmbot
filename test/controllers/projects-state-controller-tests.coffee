{ createUser, createProject, message } = require '../helpers/test-helper'
{ p, json } = require 'lightsaber'
sinon = require 'sinon'
ProjectsStateController = require '../../src/controllers/projects-state-controller'
User = require '../../src/models/user'
ColuInfo = require '../../src/services/colu-info'
ShowView = require '../../src/views/projects/show-view'

describe 'ProjectsStateController', ->
  msg = null
  controller = null
#  spy = null
  currentUser = null

  setup = =>
    App.robot =
      adapter: {}

    App.pmReply = (msg, textOrAttachments)=>
      reply = textOrAttachments.text or textOrAttachments
      msg.parts.push reply

    createUser
      state: "projects#show"
    .then (@currentUser)=>
      currentUser = @currentUser
      msg = message('', {@currentUser})
      controller = new ProjectsStateController(msg)

  describe '#show', ->
    describe "when colu is up", ->
      it "shows an error if project doesn't exist", ->
        setup()
        .then =>
          controller.show()
        .then ->
          msg.parts[0].should.eq 'Couldn\'t find current project with name "some project id"'
          msg.currentUser.get('state').should.eq 'projects#index'

    describe "when colu is down", ->
      beforeEach ->
        sinon.stub(ColuInfo::, "allHolders").throws(new Promise.OperationalError("bang"))
        sinon.spy(ShowView, 'create')

      afterEach ->
        ColuInfo.prototype.allHolders.restore?()
        ShowView.create.restore?()

      it "shows an error if colu is down", ->
        setup()
        .then =>
          createProject()
        .then (@project)=>
          controller.show()
        .then (response)->
          currentUser.get("state").should.eq "projects#show"
          json(response).should.match /SOME PROJECT ID/
          ShowView.create.should.have.been.called
          ShowView.create.getCall(0).args[0]['coluError'].should.eq 'bang'

  describe '#capTable', ->
    it "shows an error if project doesn't exist", ->
      setup().then =>
        controller.show()
        .then ->
          msg.parts[0].should.eq 'Couldn\'t find current project with name "some project id"'
          msg.currentUser.get('state').should.eq 'projects#index'
#          spy.should.have.been.calledWith("Couldn't find current project")

  describe '#rewardsList', ->
    it "shows an error if project doesn't exist", ->
      setup().then =>
        controller.show()
        .then ->
          msg.parts[0].should.eq 'Couldn\'t find current project with name "some project id"'
          msg.currentUser.get('state').should.eq 'projects#index'
#          spy.should.have.been.calledWith("Couldn't find current project")
