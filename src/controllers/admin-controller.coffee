{log, p, pjson} = require 'lightsaber'
ApplicationController = require './application-controller'
Promise = require 'bluebird'
DCO = require '../models/dco'
swarmbot = require '../models/swarmbot'
Award = require '../models/award'
User = require '../models/user'
AwardCollection = require '../collections/award-collection'
{ values, assign, map } = require 'lodash'

class AdminController extends ApplicationController

  award: (@msg, { awardName, awardee, dcoKey })->
    @community = dcoKey
    @getDco()
    .then (dco)-> dco.fetch()
    .then (dco)=>
      if @currentUser().canUpdate(dco)
        User.findBySlackUsername(awardee).then (user)=>
          awardeeAddress = user.get('btc_address')

          if awardeeAddress?
            award = new Award({name: awardName}, parent: dco)

            award.fetch().then (award)=>
              if award.get('awarded')
                @msg.send "This task has already been awarded."
              else
                @msg.send 'Initiating transaction.'
                award.awardTo(awardeeAddress).then (body)=>
                  p "award #{award.key()} to #{awardee} :", body
                  @msg.send "Awarded task to #{awardee}.\n#{@_coloredCoinTxnUrl(body.txid)}"
                  award.set('awarded', user.key())
                .catch (error)=>
                  @msg.send "Error awarding '#{award.key()}' to #{awardee}. Unable to complete the transaction.\n #{error.message}"
                  throw error
          else
            @msg.send "#{user.get('slack_username')} must register a BTC address to receive this award!"
      else
        p "#{@currentUser().key()} trying to award bounty within dco #{dco.key()}"
        # @msg.send "Sorry, you don't have sufficient trust in this community to award this award."
        @msg.send "Sorry, you must be the progenitor of this DCO to award awards."


  setCoinName: (@msg, { coinName, dcoKey })->

    @community = dcoKey
    @getDco()
    .then (dco)-> dco.fetch()
    .then (dco)=>
      if @currentUser().canUpdate(dco)
        dco.set('coin_name', coinName)
        @msg.send "Coin name successfully updated to " + coinName

  constitute: (@msg, { constitutionLink, dcoKey })->
    @community = dcoKey
    @getDco()
    .then (dco)-> dco.fetch()
    .then (dco)=>
      if @currentUser().canUpdate(dco)
        dco.set('project_contract', constitutionLink)
        @msg.send "Project constitution successfully set"

  stats: (@msg)->

    usersRef = swarmbot.firebase().child('users')

    usersRef.orderByChild("account_created").startAt(Date.now() - (1000*60*60*24*7)).once 'value', (snapshot)=>
      @msg.send "#{snapshot.numChildren()} new users signed up in the last week."

    usersRef.orderByChild("last_active_on_slack").startAt(Date.now() - (1000*60*60*24*7)).once 'value', (snapshot)=>
      @msg.send "There are #{snapshot.numChildren()} users active in the last week."

    usersRef.orderByChild("last_active_on_slack").startAt(Date.now() - (1000*60*60*24*30)).once 'value', (snapshot)=>
      @msg.send "There are #{snapshot.numChildren()} users active in the last month."

    usersRef.once 'value', (snapshot)=>
      @msg.send "There are #{snapshot.numChildren()} users total."

module.exports = AdminController
