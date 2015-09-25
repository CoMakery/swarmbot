{log, p, pjson} = require 'lightsaber'
{ partition, sortByOrder } = require 'lodash'
{ Reputation, Claim } = require 'trust-exchange'
ApplicationController = require './application-controller'
Promise = require 'bluebird'
DCO = require '../models/dco'
Bounty = require '../models/bounty'
swarmbot = require '../models/swarmbot'
{ values } = require 'lodash'

class BountiesController extends ApplicationController
  list: (@msg, { @community }) ->
    @getDco().then (dco)=>
      dco.fetch().then (dco) =>
        bounties = dco.snapshot.child('bounties').val()
        numBounties = dco.snapshot.child('bounties').numChildren()
        if numBounties == 0
          return @msg.send "There are no bounties to display in #{dco.get('id')}."

        promises = for bountyName, data of bounties
          do (bountyName, data) ->
            Reputation.score bountyName,
              firebase: path: "projects/#{@community}/bounties"
            .then (score) ->
              name: bountyName
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
    .error (error) =>
      log "error" + error
      @msg.send "Please either set a community or specify the community in the command."

  show: (@msg, { bountyName, @community }) ->
    @getDco().then (dco) =>
      bounty = new Bounty({id: bountyName}, parent: dco)
      bounty.fetch().then (bounty) =>
        p bounty.attributes
        msgs = for k, v of bounty.attributes
          "#{k} : #{v}"
        @msg.send msgs.join("\n")

  award: (msg, { bountyName, awardee, dcoKey }) ->
    activeUser = msg.robot.whose msg

    dco = DCO.find dcoKey
    # TODO: check to make sure activeUser is owner of DCO
    dco.fetch().then (myDco) ->
      p "owner", myDco.get "owner"
      p "activeUser", activeUser
      if myDco.get("owner") == activeUser

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
      else
        msg.send "Sorry, you don't have sufficient trust in this community to award this bounty."

  create: (@msg, { bountyName, amount, @community }) ->
    @getDco().then (dco) =>
      dco.createBounty({ bountyName, amount }).then =>
        @msg.send 'bounty created'
      .error (error) =>
        log "bounty creation error: " + error
        @msg.send "error: " + error

  rate: (@msg, { @community, bountyName, rating }) ->
    @getDco().then (dco) =>
      user = @currentUser()

      Bounty.find(bountyName, parent: dco).fetch().then (bounty) =>
        unless bounty.exists()
          return @msg.send "Could not find the bounty '#{bounty.get('id')}'. Please check that it exists."

        Claim.put {
          source: user.get('id')
          target: bounty.get('id')
          value: rating * 0.01  # convert to percentage
        }, {
          firebase: path: "projects/#{dco.get('id')}/bounties/#{bountyName}/ratings"
        }
          .then (messages) =>
            replies = for message in messages
              "Rating saved to #{message}"
            @msg.send replies.join "\n"
          .catch (error) =>
            @msg.send "Rating failed: #{error}\n#{error.stack}"
    .error (error)=>
      @msg.send "Which community? Please either set a community or specify it in the command."

module.exports = BountiesController
