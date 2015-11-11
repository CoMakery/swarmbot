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
    .then (proposal) =>
      @render new IndexView(proposal)

  show: (data) ->
    # TODO: Is there a way to do this where we don't have to query the whole DCO every time?
    @getDco()
    .then (dco)=>
      Proposal.find data.proposalId, parent: dco
    .then (proposal)=>
      Solution.find data.solutionId, parent: proposal
    .then (solution)=>
      @render new ShowView(solution)

  create: (data)->
    if @input?
      if not data.name?
        data.name = @input
      else if not data.link?
        data.link = @input
        return @getDco()
          .then (@dco) => Proposal.find data.proposalId, parent: @dco
          .then (@proposal) =>
            data.userId = @currentUser.key()
            @proposal.createSolution data
          .then (solution) =>
            # Notify Progenitor
            User.find @dco.get('project_owner')
            .then (owner)=>
              @msg.robot.messageRoom owner.get('slack_username'),
                "*New Solution Submitted for #{@proposal.key()}*\n #{solution.key()}\n#{solution.get('link')}"

            @msg.send "Your solution has been submitted and will be reviewed!\n"
            @execute transition: 'exit', data: { proposalId: data.proposalId }

    @currentUser.set 'stateData', data
    .then =>
      @render new CreateView data

  sendReward: (data) ->
    if @input? and @input.match /^\d+$/
      rewardAmount = @input
      @getDco()
      .then (@dco) => Proposal.find(data.proposalId, parent: @dco)
      .then (@proposal) => Solution.find(data.solutionId, parent: @proposal)
      .then (@solution) => User.find @solution.get 'userId'
      .then (@recipient) =>
        unless @recipient.get('btc_address')?
          throw Promise.OperationalError("This user doesn't have a registered Bitcoin address!")
        @msg.send 'Initiating transaction...'
        @proposal.awardTo(@recipient.get('btc_address'), rewardAmount)
      .then (body) =>
        @msg.send 'Reward sent!'
        debug "Reward #{@proposal.key()}/#{@solution.key()} to #{@recipient.get('slack_username')} :", body
        txUrl = @_coloredCoinTxUrl(body.txid)
        @msg.send "Awarded proposal to #{@recipient.get('slack_username')}.\n#{txUrl}"
        # PM message
        @msg.robot.messageRoom @recipient.get('slack_username'),
          "Congratulations! You have received #{rewardAmount} community coins for your solution '#{@solution.key()}'\n#{@_coloredCoinTxUrl(body.txid)}"
      .error (error) =>
        @msg.send error.message
      .then =>
        @execute transition: 'exit'
      .catch (error) =>
        @msg.send "Error awarding '#{@proposal?.key()}' to #{@recipient?.get('slack_username')}. Unable to complete the transaction.\n #{error.message}"
        @execute transition: 'exit'
        throw error

    else
      @getDco()
      .then (dco) => Proposal.find data.proposalId, parent: dco
      .then (proposal) => Solution.find data.solutionId, parent: proposal
      .then (solution) => User.find solution.get('userId')
      .then (solutionCreator) =>
        recipientUsername = solutionCreator.get 'slack_username'
        @render new SendRewardView {data, recipientUsername}


  upvote: (data) ->
    @getDco().then (dco) =>
      Proposal.find data.proposalId, parent: dco
    .then (proposal) =>
      Solution.find(data.solutionId, parent: proposal)
    .then (solution) =>
      unless solution.exists()
        throw new Error "Could not find the solution '#{data.solutionId}'. Please verify that it exists."
      solution.upvote @currentUser
    .then =>
      @redirect "Your vote has been recorded."

  _coloredCoinTxUrl: (txId) ->
    url = ["http://coloredcoins.org/explorer"]
    url.push 'testnet' if process.env.COLU_NETWORK == 'testnet'
    url.push 'tx', txId
    url.join('/')

module.exports = SolutionsStateController
