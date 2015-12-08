debug = require('debug')('app')
{ log, p, pjson } = require 'lightsaber'
{ isEmpty, last } = require 'lodash'
Promise = require 'bluebird'
ApplicationController = require './application-state-controller'
Proposal = require '../models/proposal'
Reward = require '../models/reward'
User = require '../models/user'
CreateView = require '../views/solutions/create-view'

class SolutionsStateController extends ApplicationController
  cleanUsername: (username)->
    username = username.trim()
    username = username.slice(1) if username[0] is '@'
    username = username.slice(0, username.length-1) if last(username) is ':'
    username

  create: (data={})->
    @getDco()
    .then (dco)=> dco.fetch()
    .then (@dco)=>
      if not @input
        # fall through to render
      else if not data.recipient?
        User.findBySlackUsername @cleanUsername @input
        .then (recipient)=>
          unless recipient.get('btc_address')?
            throw Promise.OperationalError("This user doesn't have a registered Bitcoin address!")
          data.recipient = recipient.key()
        .error (error)=>
          @errorMessage = error.message
      else if not data.awardId?
        # Note : set by the menu item when selecting award
      else if not data.rewardAmount?
        data.rewardAmount = @input
      else if not data.description?
        data.description = @input.trim().replace /\$,/, ''
        data.issuer = @currentUser.key()
        Reward.push(data, parent: @dco)
        .then (@reward)=> User.find data.recipient
        .then (@recipient)=>
          Proposal.find(data.awardId, parent: @dco)
        .then (proposal)=>
          @sendReward(proposal, data.rewardAmount)
          Promise.resolve() # don't wait on sendReward's promise, which waits for the blockchain

    .then =>
      if data.recipient
        User.find data.recipient

    .then (recipient)=>
      @sendWarning @errorMessage if @errorMessage
      if @reward
        @execute transition: 'exit', flashMessage: "Initiating transaction.
                                                    This will take some time to confirm in the blockchain.
                                                    We will private message both you and @#{@recipient.get('slack_username')}
                                                    when the transaction is complete."
      else
        @currentUser.set 'stateData', data
        .then => @render new CreateView @dco, data, {recipient}

  setStateData: (data)->
    @currentUser.set 'stateData', data
    .then => @redirect()

# only admin:
      # @getDco()
      # .then (@dco)=>
      #   if @dco.get('project_owner') is @currentUser.key()
      #     Proposal.find(data.proposalId, parent: @dco)
      #   else
      #     Promise.reject(Promise.OperationalError "Only the creator of this project can send rewards")

  sendReward: (proposal, rewardAmount)->
    proposal.awardTo(@recipient.get('btc_address'), rewardAmount)
    .then (body)=>
      @sendInfo 'Reward sent!'
      debug "Reward #{proposal.key()} to #{@recipient.get('slack_username')} :", body
      txUrl = @_coloredCoinTxUrl(body.txid)
      @sendInfo "Awarded proposal to #{@recipient.get('slack_username')}.\n#{txUrl}"
      @msg.robot.messageRoom @recipient.get('slack_username'),
        "Congratulations! You have received #{rewardAmount} project coins\n#{@_coloredCoinTxUrl(body.txid)}"
    .error (error)=>
      @sendWarning error.message
    .catch (error)=>
      @sendWarning "Error awarding '#{proposal?.key()}' to #{@recipient?.get('slack_username')}. Unable to complete the transaction.\n #{error.message}"
      throw error

module.exports = SolutionsStateController
