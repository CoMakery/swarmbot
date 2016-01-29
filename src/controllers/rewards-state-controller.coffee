{ log, p, pjson } = require 'lightsaber'
{ isEmpty, last } = require 'lodash'
ApplicationStateController = require './application-state-controller'
RewardType = require '../models/reward-type'
Reward = require '../models/reward'
User = require '../models/user'
CreateView = require '../views/rewards/create-view'

class RewardsStateController extends ApplicationStateController
  cleanUsername: (username)->
    username = username.trim()
    username = username.slice(1) if username[0] is '@'
    username = username.slice(0, username.length-1) if last(username) is ':'
    username

  create: (data={})->
    @getProject()
    .then (project)=> project.fetch()
    .then (@project)=>
      if @project.get('projectOwner') != @currentUser.get('name')
        throw Promise.OperationalError "Only project administrators can award coins"

      if @project.rewardTypes().isEmpty()
        throw Promise.OperationalError "There are no award types.  Please create one and then try sending an award."

      if not @input
        # fall through to render
      else if not data.recipient?
        @userName = @cleanUsername @input
        User.setupToReceiveBitcoin(@currentUser, @userName, data, @sendPm)
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
          @sendReward(@recipient, rewardType, data.rewardAmount)
          Promise.resolve() # don't wait on sendReward's promise, which waits for the blockchain

    .then =>
      if data.recipient
        User.find data.recipient

    .then (recipient)=>
      @sendWarning @errorMessage if @errorMessage
      if @reward
        @execute transition: 'exit', flashMessage: "Initiating transaction.
                                                    This will take some time to confirm in the blockchain.
                                                    We will private message both you and @#{@recipient.get('slackUsername')}
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
      #   if @project.get('projectOwner') is @currentUser.key()
      #     RewardType.find(data.rewardTypeId, parent: @project)
      #   else
      #     Promise.reject(Promise.OperationalError "Only the creator of this project can send rewards")

  sendReward: (recipient, rewardType, rewardAmount)->
    rewardType.awardTo(recipient.get('btcAddress'), rewardAmount)
    .then (body)=>
      @sendInfo 'Reward sent!'
      debug "Reward #{rewardType.key()} to #{recipient.get('slackUsername')} :", body
      txUrl = @_coloredCoinTxUrl(body.txid)
      @sendInfo "Awarded award to #{recipient.get('slackUsername')}.\n#{txUrl}"
      @msg.robot.messageRoom recipient.get('slackUsername'),
        "Congratulations! You have received #{rewardAmount} project coins\n#{@_coloredCoinTxUrl(body.txid)}"
    .catch (error)=>
      @sendWarning "Error awarding '#{rewardType?.key()}' to #{recipient?.get('slackUsername')}. Unable to complete the transaction.\n#{error.message}"

module.exports = RewardsStateController
