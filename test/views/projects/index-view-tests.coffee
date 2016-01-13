{ createProject, createUser } = require '../../helpers/test-helper'
{ json, p } = require 'lightsaber'
Project = require '../../../src/models/project.coffee'
IndexView = require '../../../src/views/projects/index-view.coffee'

describe 'IndexView', ->
  describe 'render', ->
    it 'informs the user if there is a colu error', ->
      Promise.all [
        createProject(name: "Project X")
        createProject(name: "Project Y")
        createUser()
        ]
      .then (@createdItems)=>
        [projectX, projectY, user] = @createdItems
        view = new IndexView({projects: [projectX, projectY], currentUser: user, userBalances: [], coluError: "Down message"})
        reply = view.render()
        jreply = json(reply)
        jreply.should.match /Your Project Coins/
        jreply.should.match /Down message/

    it 'returns a bunch of project info for all the projects', ->
      Promise.all [
        createProject(name: "Project X")
        createProject(name: "Project Y")
        createUser()
        ]
      .then (@createdItems)=>
        [projectX, projectY, user] = @createdItems
        view = new IndexView({projects: [projectX, projectY], currentUser: user, userBalances: []})
        reply = view.render()
        jreply = json(reply)
        jreply.should.match /Welcome friend! I am here to help you contribute to projects and receive project coins. Project coins track your share of a project using a trusty blockchain./
        jreply.should.match /Let's get started!  Type 1, hit enter, and create your first project./
        jreply.should.match /Contribute to projects and receive project coins!/
        jreply.should.match /Choose a Project/
        jreply.should.match /A: Project X/
        jreply.should.match /B: Project Y/
        jreply.should.match /Your Project Coins/

        jreply.should.not.match /undefined/
        jreply.should.match /No Coins yet/

        jreply.should.match /bitcoin address: 3HNSiAq7wFDaPsYDcUxNSRMD78qVcYKicw/
        jreply.should.match /Actions/
        jreply.should.match /1: create your project/
        jreply.should.match /2: set your bitcoin address/
        jreply.should.match /3: suggest a swarmbot improvement/
