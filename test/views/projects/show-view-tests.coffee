{ createProject, createUser } = require '../../helpers/test-helper'
{ json, p } = require 'lightsaber'
Project = require '../../../src/models/project.coffee'
ShowView = require '../../../src/views/projects/show-view.coffee'

describe 'ShowView', ->
  describe 'render', ->
    it 'informs user when colu data is unavailable', ->
      Promise.all [
          createProject(name: "Project X")
          createUser()
        ]
      .then (@createdItems)=>
        [projectX, user] = @createdItems
        view = new ShowView(project: projectX, currentUser: user, userBalance: [], coluError: "Down message")
        reply = view.render()
        jreply = json(reply)
        jreply.should.match /PROJECT X/
        jreply.should.match /Down message/
