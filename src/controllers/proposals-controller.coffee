{log, p, pjson} = require 'lightsaber'
{ Reputation, Claim } = require 'trust-exchange'
ApplicationController = require './application-controller'
Promise = require 'bluebird'
DCO = require '../models/dco'
swarmbot = require '../models/swarmbot'
Proposal = require '../models/proposal'
User = require '../models/user'
ProposalCollection = require '../collections/proposal-collection'
{ values, assign, map } = require 'lodash'

class ProposalsController extends ApplicationController

  list: (@msg, { @community }) ->
    @getDco().then (dco)=>
      dco.fetch().then (dco) =>
        proposals = new ProposalCollection(dco.snapshot.child('proposals'), parent: dco)
        if proposals.isEmpty()
          return @msg.send "There are no proposals to display in #{dco.get('id')}."

        proposals.sortByReputationScore()
        messages = proposals.map @_proposalMessage
        @msg.send messages.join("\n")

    .error(@_showError)

  listApproved: (@msg, { @community }) ->
    @getDco().then (dco)=>
      dco.fetch().then (dco) =>
        proposals = new ProposalCollection(dco.snapshot.child('proposals'), parent: dco)

        proposals.filter (proposal) ->
          proposal.ratings().size() > 0 &&
          proposal.ratings().score() > 50 &&
          !proposal.get('awarded')?

        proposals.sortByReputationScore()
        messages = proposals.map @_proposalMessage

        if messages.length == 0
          return @msg.send "There are no approved bounties for #{dco.get('id')}.\n Type 'proposals' to see what needs to be approved!"


        @msg.send messages.join("\n")

    .error(@_showError)


  award: (@msg, { proposalName, awardee, dcoKey }) ->
    @community = dcoKey
    @getDco()
    .then (dco) -> dco.fetch()
    .then (dco) =>
      if @currentUser().canUpdate(dco)
        User.findBySlackUsername(awardee).then (user)=>
          awardeeAddress = user.get('btc_address')

          if awardeeAddress?
            proposal = new Proposal({id: proposalName}, parent: dco)

            proposal.fetch().then (proposal) =>
              if not proposal.exists()
                @msg.send "Proposal '#{proposal.get('id')}' does not exist. Did you misspell it?"
              else if proposal.get('awarded')
                @msg.send "This proposal has already been awarded."
              else if not proposal.get('amount') or proposal.get('amount') is '0'
                @msg.send "This proposal does not have a bounty associated with it.  If you'd like to award it, first add a bounty."
              else
                @msg.send 'Initiating transaction...'
                proposal.awardTo(awardeeAddress).then (body)=>
                  p "award #{proposal.get('id')} to #{awardee} :", body
                  @msg.send "Awarded proposal to #{awardee}.\n#{@_coloredCoinTxnUrl(body.txid)}"
                  proposal.set('awarded', user.get('id'))
                .catch (error)=>
                  @msg.send "Error awarding '#{proposal.get('id')}' to #{awardee}. Unable to complete the transaction.\n #{error.message}"
                  throw error
          else
            @msg.send "#{user.get('slack_username')} must register a BTC address to receive this award!"
      else
        p "#{@currentUser().get('id')} trying to award bounty within dco #{dco.get('id')}"
        # @msg.send "Sorry, you don't have sufficient trust in this community to award this proposal."
        @msg.send "Sorry, you must be the progenitor of this DCO to award proposals."

  create: (@msg, { proposalName, amount, @community }) ->
    @getDco()
    .then (@dco) =>
      @dco.createProposal({ id: proposalName, amount })
    .then =>
      @msg.send "Proposal '#{proposalName}' created in community '#{@dco.get('id')}'"
    .error(@_showError)

  swarmbotSuggestion: (@msg, { suggestion }) ->
    DCO.find(swarmbot.feedbackDcokey)
    .then (dco) =>
      if dco.exists()
        @create @msg, { proposalName: suggestion, amount: 0, community: swarmbot.feedbackDcokey }
      else
        @msg.send "The community '#{swarmbot.feedbackDcokey}' does not exist. Please ask your amazing swarmbot admin to create it!"

  _proposalMessage: (proposal) ->
    text = "Proposal #{proposal.get('id')}"
    if (proposal.get('amount') && proposal.get('amount') > 0)
      text += " Reward $#{proposal.get('amount')}"
    score = proposal.ratings().score()
    text += " Rating: #{score}%" unless isNaN(score)
    text += " (awarded)" if proposal.get('awarded')?
    text

  _coloredCoinTxnUrl: (txnId) ->
    url = ["http://coloredcoins.org/explorer"]
    url.push 'testnet' if process.env.COLU_NETWORK == 'testnet'
    url.push "tx/#{txnId}"

    url.join('/')

module.exports = ProposalsController
