{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './state-application-controller'
Proposal = require '../models/proposal'
DcoCollection = require '../collections/dco-collection'
CreateView = require '../views/solutions/create-view'

class SolutionsStateController extends ApplicationController
  create: (data)->

    if @input?
      if not data.id?
        data.id = @input
      else if not data.link?
        data.link = @input
        @getDco()
        .then (dco) => Proposal.find data.proposalId, parent: dco
        .then (proposal) => proposal.createSolution data
        .then (solution) =>
          @msg.send "Your solution has been submitted and will be reviewed!"
          # go back to proposals#show
          @execute transition: 'exit', data: {id: data.proposalId}

    # data ?= {}
    @currentUser.set 'stateData', data

    @render(new CreateView(data))
module.exports = SolutionsStateController
