{ log, p, pjson } = require 'lightsaber'
debug = require('debug')('app')
{ isEmpty } = require 'lodash'
Promise = require 'bluebird'
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
    .then (proposal)=>
      @render new IndexView(proposal)

  show: (data)->
    @getDco()
    .then (dco)=>
      Proposal.find data.proposalId, parent: dco
    .then (proposal)=>
      Solution.find data.solutionId, parent: proposal
    .then (solution)=>
      @render new ShowView(solution, @currentUser)

  create: (data)->
    if @input?
      if not data.name?
        data.name = @input
      else if not data.link?
        data.link = @input
        return @getDco()
          .then (@dco)=> Proposal.find data.proposalId, parent: @dco
          .then (@proposal)=>
            data.userId = @currentUser.key()
            @proposal.createSolution data
          .then (solution)=>
            # Notify Progenitor
            User.find @dco.get('project_owner')
            .then (owner)=>
              @msg.robot.messageRoom owner.get('slack_username'),
                "*New Solution Submitted for #{@proposal.key()}*\n #{solution.key()}\n#{solution.get('link')}"

            @sendInfo "Your solution has been submitted and will be reviewed!"
            @execute transition: 'exit', data: { proposalId: data.proposalId }

    @currentUser.set 'stateData', data
    .then =>
      @render new CreateView data

  sendReward: (data)->
    if @input? and @input.match /^\d+$/
      rewardAmount = @input
      @getDco()
      .then (@dco)=>
        if @dco.get('project_owner') is @currentUser.key()
          Proposal.find(data.proposalId, parent: @dco)
        else
          Promise.reject(Promise.OperationalError "Only the creator of this project can send rewards")
      .then (@proposal)=> Solution.find(data.solutionId, parent: @proposal)
      .then (@solution)=> User.find @solution.get 'userId'
      .then (@recipient)=>
        unless @recipient.get('btc_address')?
          throw Promise.OperationalError("This user doesn't have a registered Bitcoin address!")
        @sendInfo "Initiating transaction.
          This will take some time to confirm in the blockchain.
          We will private message both yourself and #{@recipient.get('slack_username')}
          when the transaction is complete."
        @proposal.awardTo(@recipient.get('btc_address'), rewardAmount)
      .then (body)=>
        @sendInfo 'Reward sent!'
        debug "Reward #{@proposal.key()}/#{@solution.key()} to #{@recipient.get('slack_username')} :", body
        txUrl = @_coloredCoinTxUrl(body.txid)
        @sendInfo "Awarded proposal to #{@recipient.get('slack_username')}.\n#{txUrl}"
        # PM message
        @msg.robot.messageRoom @recipient.get('slack_username'),
          "Congratulations! You have received #{rewardAmount} project coins for your solution '#{@solution.key()}'\n#{@_coloredCoinTxUrl(body.txid)}"
      .error (error)=>
        @sendWarning error.message
      .then =>
        @execute transition: 'exit', data: data
      .catch (error)=>
        @sendWarning "Error awarding '#{@proposal?.key()}' to #{@recipient?.get('slack_username')}. Unable to complete the transaction.\n #{error.message}"
        @execute transition: 'exit', data: data
        throw error

    else
      @getDco()
      .then (dco)=> Proposal.find data.proposalId, parent: dco
      .then (proposal)=> Solution.find data.solutionId, parent: proposal
      .then (solution)=> User.find solution.get('userId')
      .then (solutionCreator)=>
        recipientUsername = solutionCreator.get 'slack_username'
        @render new SendRewardView {data, recipientUsername}

module.exports = SolutionsStateController
