{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-state-controller'
Proposal = require '../models/proposal'
Solution = require '../models/solution'
User = require '../models/user'
DcoCollection = require '../collections/dco-collection'
IndexView = require '../views/solutions/index-view'
ShowView = require '../views/solutions/show-view'
CreateView = require '../views/solutions/create-view'
SendRewardView = require '../views/solutions/send-reward-view'

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
          .then (@dco) => Proposal.find data.proposalId, parent: @dco
          .then (@proposal) => @proposal.createSolution data
          .then (solution) =>
            # Notify Progenitor
            User.find @dco.get('project_owner')
            .then (owner)=>
              @msg.robot.messageRoom owner.get('slack_username'),
                "*New Solution Submitted for #{@proposal.get('id')}*\n #{solution.get('id')}\n#{solution.get('link')}"

            @msg.send "Your solution has been submitted and will be reviewed!\n"
            @execute transition: 'exit', data: { proposalId: data.proposalId }

    @currentUser.set 'stateData', data
    .then =>
      @render new CreateView data

  sendReward: (data) ->
    @getDco()
    .then (dco) => Proposal.find data.proposalId, parent: dco
    .then (proposal) => Solution.find data.solutionId, parent: proposal
    .then (solution) => User.find solution.get('userId')
    .then (solutionCreator) =>
      recipientUsername = solutionCreator.get 'slack_username'
      @render new SendRewardView {data, recipientUsername}

module.exports = SolutionsStateController
