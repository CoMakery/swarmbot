{log, p, pjson} = require 'lightsaber'
{ Reputation, Claim } = require 'trust-exchange'
ApplicationController = require './application-controller'
Promise = require 'bluebird'
DCO = require '../models/dco'
swarmbot = require '../models/swarmbot'
Proposal = require '../models/proposal'
ProposalCollection = require '../collections/proposal-collection'
{ values, assign, map } = require 'lodash'

class ProposalsController extends ApplicationController

  #TODO: Should go through TrustExchange and get approved elements

  listApproved: (@msg, { @community }) ->

    # TODO:  text += " Rating: #{proposal.score}%" if ?
        # if ratingsCount > 1 && proposal.score > 50%

  list: (@msg, { @community }) ->
    @getDco().then (dco)=>
      dco.fetch().then (dco) =>
        proposals = new ProposalCollection(dco.snapshot.child('proposals'), parent: dco)
        if proposals.isEmpty()
          return @msg.send "There are no proposals to display in #{dco.get('id')}."

        Promise.all(proposals.getReputationScores()).then (proposals) =>
          messages = proposals.map (proposal)->
            text = "Proposal #{proposal.get('name')}"
            text += " Reward #{proposal.get('amount')}" if proposal.get('amount')?
            text += " Rating: #{proposal.get('reputationScore')}%" if proposal.get('reputationScore')?
            text
          @msg.send messages.join("\n")

    .error(@noCommunityError)

  show: (@msg, { proposalName, @community }) ->
    @getDco().then (dco) =>
      proposal = new Bounty({id: proposalName}, parent: dco)
      proposal.fetch().then (proposal) =>
        p proposal.attributes
        msgs = for k, v of proposal.attributes
          "#{k} : #{v}"
        @msg.send msgs.join("\n")

  award: (msg, { proposalName, awardee, dcoKey }) ->
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
            dco.awardBounty {proposalName, awardeeAddress}
            message = "Awarded proposal to #{awardee}"
            msg.send message
          else
            msg.send "User not yet registered"
      else
        msg.send "Sorry, you don't have sufficient trust in this community to award this proposal."

  create: (@msg, { proposalName, amount, @community }) ->

    @getDco().bind(@).then (dco) ->
      dco.createBounty({ proposalName, amount }).then =>
        @msg.send 'proposal created'
      .catch (error) =>
        log "proposal creation error: " + error
        @msg.send "error: " + error

    .error(@noCommunityError)

  #TODO: possibly incorporate some gatekeeping here (i.e. only members of a DCO can vote on the output)
  rate: (@msg, { @community, proposalName, rating }) ->
    @getDco().then (dco) =>
      user = @currentUser()

      Proposal.find(proposalName, parent: dco).fetch().then (proposal) =>
        unless proposal.exists()
          return @msg.send "Could not find the proposal '#{proposal.get('id')}'. Please check that it exists."

        Claim.put {
          source: user.get('id')
          target: proposal.get('id')
          value: rating * 0.01  # convert to percentage
        }, {
          firebase: path: "projects/#{dco.get('id')}/proposals/#{proposalName}/ratings"
        }
          .then (messages) =>
            replies = for message in messages
              "Rating saved to #{message}"
            @msg.send replies.join "\n"
          .catch (error) =>
            @msg.send "Rating failed: #{error}\n#{error.stack}"
    .error(@noCommunityError)

  noCommunityError: ->
    @msg.send "Please either set a community or specify the community in the command."


module.exports = ProposalsController
