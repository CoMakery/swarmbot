{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-controller'
ProposalCollection = require '../collections/proposal-collection'

class ProposalsStateController extends ApplicationController
  process: ->
    message = @msg.match[1]

    p "message: #{message}"
    p "@currentUser: #{@currentUser.get('slack_username')}"

    switch @currentUser.current
      when 'home'
        switch message
          when 'help' then @help()
          when '1'
            @currentUser.show(1)
            @router.route(@msg)
          when '2' then p 2
          when '0' then @currentUser.exit()

      when 'proposals-index'
        switch message
          when '1' then @show(1)
          when '2' then p 2
          when '0' then @currentUser.exit()

      when 'proposals-show'
        switch message
          when '1' then @show(1)
          when '0' then @currentUser.exit(); @router.route(@msg)

  help: ->
    @getDco()
    .then (dco) => dco.fetch()
    .then (dco) =>
      proposals = new ProposalCollection(dco.snapshot.child('proposals'), parent: dco)
      # if proposals.isEmpty()
      #   return @msg.send "There are no proposals to display in #{dco.get('id')}."
      proposals.sortByReputationScore()
      messages = proposals.map(@_proposalMessage)[0...5]
      messages = for message, i in messages
        "#{i+1}: #{message}"

      @msg.send """
        #{messages}
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

  show: (proposalId) ->

    p 'showing ' + proposalId

module.exports = ProposalsStateController
