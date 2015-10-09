{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-controller'
ProposalCollection = require '../collections/proposal-collection'
Proposal = require '../models/proposal'
HomeMenuView = require '../views/proposals/home-menu-view'
ShowView = require '../views/proposals/show-view'

class ProposalsStateController extends ApplicationController
  redirect: ->
    @msg.match[1] = 'help'
    @router.route(@msg)

  execute: (action) ->
    if action.command?
      @[action.command]()

    if action.transition?
      @currentUser[action.transition]()
      @redirect()

  process: ->
    message = @msg.match[1].toLowerCase()
    lastMenuItems = @currentUser.get('menu')

    action = lastMenuItems?[message]
    if action?
      @execute(action)
    else
      switch @currentUser.current
        when 'home'
          @home()
        when 'proposalsShow'
          @show action

        # when 'proposalsIndex'
        #   switch message
        #     when '1' then @show(1)
        #     when '2' then p 2
        #     when 'x' then @currentUser.exit()

  show: (proposalInfo) ->
    proposalId = proposalInfo?.object?.id ? throw new Error
    @getDco()
    .then (dco) => Proposal.find proposalId, parent: dco
    .then (proposal) =>
      @msg.send @_proposalMessage proposal
      view = new ShowView(proposal).build()
      @msg.send view.render()

  home: ->
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
