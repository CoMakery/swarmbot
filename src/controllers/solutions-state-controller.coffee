{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-state-controller'
Proposal = require '../models/proposal'
Solution = require '../models/solution'
DcoCollection = require '../collections/dco-collection'
IndexView = require '../views/solutions/index-view'
ShowView = require '../views/solutions/show-view'
CreateView = require '../views/solutions/create-view'

class SolutionsStateController extends ApplicationController
  index: (params)->
    @getDco()
    .then (dco)=>
      Proposal.find(params.proposalId, parent: dco)
    .then (proposal) =>
      @render new IndexView(proposal)

  show: (params) ->
    # TODO: Is there a way to do this where we don't have to query the whole DCO every time?
    @getDco()
    .then (dco)=>
      Proposal.find params.proposalId, parent: dco
    .then (proposal)=>
      Solution.find params.id, parent: proposal
    .then (solution)=>
      @render new ShowView(solution)

  create: (data)->

    if @input?
      if not data.id?
        data.id = @input
      else if not data.link?
        data.link = @input
        return @getDco()
        .then (dco) => Proposal.find data.proposalId, parent: dco
        .then (proposal) => proposal.createSolution data
        .then (solution) =>
          @msg.send "Your solution has been submitted and will be reviewed!\n"
          @execute transition: 'exit', data: { proposalId: data.proposalId }

    @currentUser.set 'stateData', data

    @render(new CreateView(data))
module.exports = SolutionsStateController
