{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-controller'
ProposalCollection = require '../collections/proposal-collection'
Proposal = require '../models/proposal'

class ProposalsStateController extends ApplicationController

  process: ->
    message = @msg.match[1]

    switch @currentUser.current
      when 'home'
        # choice = Number message
        if message is 'help' then @homeInfo()
        else if choice = message.match(/^[1-5]$/)?[0]
          @currentUser.show(choice)
          @msg.match[1] = 'help'
          @router.route(@msg)
        else if message.match(/^x$/i) then @currentUser.exit()

      when 'proposals-index'
        switch message
          when '1' then @show(1)
          when '2' then p 2
          when 'x' then @currentUser.exit()

      when 'proposals-show'
        switch message
          when 'x' then @currentUser.exit(); @router.route(@msg)
          when 'help' then @showInfo(1)

  showInfo: (proposalId) ->
    @msg.send "showing proposal show for id #{proposalId}"

  show: (proposalId) ->
    @getDco()
    .then (dco) => Proposal.find proposalId, parent: dco
    .then (proposal) => @msg.send @_proposalMessage proposal

  homeInfo: ->
    @getDco()
    .then (dco) => dco.fetch()
    .then (dco) =>
      proposals = new ProposalCollection(dco.snapshot.child('proposals'), parent: dco)
      # if proposals.isEmpty()
      #   return @msg.send "There are no proposals to display in #{dco.get('id')}."
      proposals.sortByReputationScore()
      messages = proposals.map(@_proposalMessage)[0...5]

      @user.menu.clear()
      messages = for message, i in messages
        @user.menu.set i+1, proposals[i].get('id')
      @user.set 'menu', menu.items

      menuLines = for number, proposalId of @user.menu.items
        "#{number}: #{@_proposalMessage proposalId}"

      @msg.send """
        #{menuLines.join "\n"}
        x: Exit
        """

    .error(@_showError)

  _proposalMessage: (proposal) ->
    text = "Proposal #{proposal.get('id')}"
    text += " Reward #{proposal.get('amount')}" if proposal.get('amount')?
    score = proposal.ratings().score()
    text += " Rating: #{score}%" unless isNaN(score)
    text += " (awarded)" if proposal.get('awarded')?
    text

module.exports = ProposalsStateController
