{log, p, pjson} = require 'lightsaber'
{ partition, sortByOrder } = require 'lodash'
{ Reputation, Claim } = require 'trust-exchange'
ApplicationController = require './application-controller'
Promise = require 'bluebird'
DCO = require '../models/dco'
swarmbot = require '../models/swarmbot'
{ values } = require 'lodash'

class MembersController extends ApplicationController


  list: (@msg, { @community }) ->
    @getDco().then (dco)=>
      dco.fetch().then (dco) =>
        members = dco.snapshot.child('members').val()
        numMembers = dco.snapshot.child('members').numChildren()
        if numMembers == 0
          return @msg.send "There are no members to display in #{dco.get('id')}."

        # promises = for proposalName, data of members
        #   do (proposalName, data) ->
        #     Reputation.score proposalName,
        #       firebase: path: "projects/#{@community}/members"
        #     .then (score) ->
        #       name: data.slack_username
        #       score: score
        p "uo"
        p "mbm", members
        # Promise.all(promises).then (members) =>
        #   # have to partition because sorting puts undefined scores at the top.
        #   [score, noScore] = partition members, (b) -> b.score?
        #   members = sortByOrder(score, ['score'], ['desc']).concat(noScore)
        messages = for m in members
          text = "Members "
          p "m", m
          text += " Member: #{m.slack_username}" if m.slack_username?
          text += " Happiness: #{m.happiness}" if m.happiness?
          text
        @msg.send messages.join("\n")

  # create: (@msg, { proposalName, amount, @community }) ->
  #
  #   @getDco().bind(@).then (dco) ->
  #     dco.createBounty({ proposalName, amount }).then =>
  #       @msg.send 'proposal created'
  #     .catch (error) =>
  #       log "proposal creation error: " + error
  #       @msg.send "error: " + error
  #
  #   .catch(@noCommunityError)
  #
  # noCommunityError: ->
  #   @msg.send "Please either set a community or specify the community in the command."
  #

# NOTE: could be interesting to rate members at some point
  # rate: (@msg, { @community, proposalName, rating }) ->
  #   @getDco().then (dco) =>
  #     user = @currentUser()
  #
  #     Bounty.find(proposalName, parent: dco).fetch().then (proposal) =>
  #       unless proposal.exists()
  #         return @msg.send "Could not find the proposal '#{proposal.get('id')}'. Please check that it exists."
  #
  #       Claim.put {
  #         source: user.get('id')
  #         target: proposal.get('id')
  #         value: rating * 0.01  # convert to percentage
  #       }, {
  #         firebase: path: "projects/#{dco.get('id')}/members/#{proposalName}/ratings"
  #       }
  #         .then (messages) =>
  #           replies = for message in messages
  #             "Rating saved to #{message}"
  #           @msg.send replies.join "\n"
  #         .catch (error) =>
  #           @msg.send "Rating failed: #{error}\n#{error.stack}"
  #   .error (error)=>
  #     @msg.send "Which community? Please either set a community or specify it in the command."

module.exports = MembersController
