debug = require('debug')('app')
{ log, p, pjson } = require 'lightsaber'
{ isEmpty, last } = require 'lodash'
Promise = require 'bluebird'
ApplicationController = require './application-state-controller'
RewardType = require '../models/reward-type'
Reward = require '../models/reward'
User = require '../models/user'
CreateView = require '../views/rewards/create-view'

class RewardsStateController extends ApplicationController
  cleanUsername: (username)->
    username = username.trim()
    username = username.slice(1) if username[0] is '@'
    username = username.slice(0, username.length-1) if last(username) is ':'
    username

  create: (data={})->
    @getProject()
    .then (project)=> project.fetch()
    .then (@project)=>
      if @project.get('project_owner') != @currentUser.get('name')
        return Promise.reject(Promise.OperationalError("Only project administrators can award coins"))

      if not @input
        # fall through to render
      else if not data.recipient?
        @userName = @cleanUsername @input
        User.findBySlackUsername @userName
        .error (error)=>
          throw Promise.OperationalError("The user @#{@userName} is not recognized. Sending them a message now.")
        .then (recipient)=>
          data.recipient = recipient.key()
          unless recipient.get('btc_address')?
            throw Promise.OperationalError("Sending a message to have @#{@userName} register a bitcoin address.")
        .error (error)=>
          App.sendMessage(@userName, "Hi! @#{@currentUser.get("slack_username")} is trying to send you project coins for '#{@currentUser.get('current_project')}'. In order to receive project coin awards please tell me your bitcoin address.")
          @errorMessage = error.message
      else if not data.rewardTypeId?
        # Note : set by the menu item when selecting rewardType
      else if not data.rewardAmount?
        data.rewardAmount = @input
      else if not data.description?
        data.description = @input.trim().replace /\$,/, ''
        data.issuer = @currentUser.key()
        @project.createReward(data)
        .then (@reward)=> User.find data.recipient
        .then (@recipient)=>
          RewardType.find(data.rewardTypeId, parent: @project)
        .then (rewardType)=>
          @sendReward(rewardType, data.rewardAmount)
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
          .then => @render new CreateView @project, data, {recipient}
    .error (error)=>
      @execute transition: 'exit', flashMessage: error.message

  setStateData: (data)->
    @currentUser.set 'stateData', data
    .then => @redirect()

  # is there a better way to use the global exit controller action?
  exitRewardTypeSelection: ->
    @reset()

# only admin:
      # @getProject()
      # .then (@project)=>
      #   if @project.get('project_owner') is @currentUser.key()
      #     RewardType.find(data.rewardTypeId, parent: @project)
      #   else
      #     Promise.reject(Promise.OperationalError "Only the creator of this project can send rewards")

  sendReward: (rewardType, rewardAmount)->
    rewardType.awardTo(@recipient.get('btc_address'), rewardAmount)
    .then (body)=>
      @sendInfo 'Reward sent!'
      debug "Reward #{rewardType.key()} to #{@recipient.get('slack_username')} :", body
      txUrl = @_coloredCoinTxUrl(body.txid)
      @sendInfo "Awarded award to #{@recipient.get('slack_username')}.\n#{txUrl}"
      @msg.robot.messageRoom @recipient.get('slack_username'),
        "Congratulations! You have received #{rewardAmount} project coins\n#{@_coloredCoinTxUrl(body.txid)}"
    .error (error)=>
      @sendWarning error.message
    .catch (error)=>
      @sendWarning "Error awarding '#{rewardType?.key()}' to #{@recipient?.get('slack_username')}. Unable to complete the transaction.\n #{error.message}"
      throw error

module.exports = RewardsStateController
