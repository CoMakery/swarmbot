{log, p, pjson} = require 'lightsaber'
{ partition, sortByOrder } = require 'lodash'
{ Reputation, Claim } = require 'trust-exchange'
ApplicationController = require './application-controller'
DCO = require '../models/dco'

class BountiesController extends ApplicationController
  list: (@msg, { @community }) ->
    @getCommunity().then (community)=>
      dco = DCO.find(community)
      dco.listBounties (snapshot) =>
        promises = for bounty, data of snapshot.val()
          do (bounty, data) ->
            Reputation.score bounty,
              firebase: path: "projects/#{community}/bounties"
            .then (score) ->
              name: bounty
              amount: data.amount
              score: score

        Promise.all(promises).then (bounties) =>
          # have to partition because sorting puts undefined scores at the top.
          [score, noScore] = partition bounties, (b) -> b.score?
          bounties = sortByOrder(score, ['score'], ['desc']).concat(noScore)
          messages = for bounty in bounties
            text = "Bounty #{bounty.name}"
            text += " Reward #{bounty.amount}" if bounty.amount?
            text += " Rating: #{bounty.score}%" if bounty.score?
            text
          @msg.send messages.join("\n")
    , =>
      @msg.send "Please either set a community or specify the community in the command."



  award: (msg, { bountyName, awardee, dcoKey }) ->
    activeUser = msg.robot.whose msg

    dco = DCO.find dcoKey

    usersRef = swarmbot.firebase().child('users')
    usersRef.orderByChild("slack_username").equalTo(awardee).on 'value', (snapshot) ->
      v = snapshot.val()
      vals = values v
      p "vals", vals
      awardeeAddress = vals[0].btc_address
      p "address", awardeeAddress

      # p "awardee", awardeeAddress values btc_address
      if(awardeeAddress)
        dco.awardBounty {bountyName, awardeeAddress}
        message = "Awarded bounty to #{awardee}"
        msg.send message
      else
        msg.send "User not yet registered"

  create: (msg, { bountyName, amount, dcoKey }) ->
    DCO.createBountyFor {dcoKey, bountyName, amount}, (error, message) ->
      msg.send error or message

  rate: (msg, { community, bounty, rating }) ->
    user = msg.robot.whose msg
    Claim.put {
      source: user
      target: bounty
      value: rating * 0.01  # convert to percentage
    }, {
      firebase: path: "projects/#{community}/bounties/#{bounty}/ratings"
    }
      .then (messages) ->
        replies = for message in messages
          "Rating saved to #{message}"
        msg.send replies.join "\n"
      .catch (error) ->
        msg.send "Rating failed: #{error}\n#{error.stack}"

module.exports = BountiesController
