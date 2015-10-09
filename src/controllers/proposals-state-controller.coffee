{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-controller'
ProposalCollection = require '../collections/proposal-collection'
Proposal = require '../models/proposal'

HomeMenuView = require '../views/proposals/home-menu-view'

class ProposalsStateController extends ApplicationController
  redirect: ->
    @msg.match[1] = 'help'
    @router.route(@msg)

  process: ->
    message = @msg.match[1]

    switch @currentUser.current
      when 'home'

        if message is 'help'
          @homeInfo()
        else if choice = message.match(/^[1-5]$/)?[0]
          @currentUser.show(choice)
          @redirect()
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
      # i have the prerequisites to build the home menu.
      # list of proposals.
      proposals = new ProposalCollection(dco.snapshot.child('proposals'), parent: dco)
      # if proposals.isEmpty()
      #   return @msg.send "There are no proposals to display in #{dco.get('id')}."
      proposals.sortByReputationScore()
      # messages = proposals.map(@_proposalMessage)[0...5]

      menu = new HomeMenuView(proposals).build()

      # i save it on the user menu.
      @currentUser.set 'menu', menu.items


      # @user.menu.clear()
      # messages = for message, i in messages
      #   @user.menu.set i+1, proposals[i].get('id')

      @msg.send menu.render()

    .error(@_showError)


module.exports = ProposalsStateController
