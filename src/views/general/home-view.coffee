{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class HomeView extends ZorkView
  constructor: (@dco, @proposals) ->
    @orderedMenu = []
    @proposalItems = []
    i = 0
    for proposal in @proposals.all()
      @proposalItems.push [@letters[i++], @proposalMenuItem proposal]

    i = 1
    # @orderedMenu.push [i++, { text: "« back", transition: 'setDco' }]
    @orderedMenu.push [i++, { text: "create a proposal", transition: 'create' }]
    @orderedMenu.push [i++, { text: "set community", transition: 'setDco' }]
    @orderedMenu.push [i++, { text: "my account", transition: 'myAccount' }]
    @orderedMenu.push [i++, { text: "cap table", command: 'capTable' }]
    @orderedMenu.push [i++, { text: "advanced commands", command: 'advanced' }]

    @menu = {}
    for [key, menuItem] in @proposalItems
      @menu[key.toLowerCase()] = menuItem if key?
    for [key, menuItem] in @orderedMenu
      @menu[key] = menuItem if key?

  render: ->
    headline = if @proposals.isEmpty() then 'No proposals' else 'Proposals'
    headline += " in #{@dco.get 'name'}"
    """
    [Home] #{@bold headline}
    #{@renderMenu()}

    Meow! Rewards are granted by community admins for accepted solutions at their discretion.
    To take an action, simply enter the number or letter at the beginning of the line.
    """

    [
      {
        color: @NAV_COLOR
        title: "community » #{(@dco.get 'name').toLowerCase()}"
      }
      {
        color: @ACTION_COLOR
        fields: [
          {
            title: 'View Current Proposals'
            value: if @proposalItems.length == 0
                "There are no proposals in this community."
              else
                @renderOrderedMenuItems(@proposalItems)
            short: true
          }
          {
            title: 'Actions'
            value: @renderOrderedMenuItems(@orderedMenu)
            short: true
          }
        ]

      }
    ]

  proposalMenuItem: (proposal) ->
    {
      text: @proposalMessage(proposal).toLowerCase()
      data: { proposalId: proposal.key() }
      transition: 'show'
    }

  proposalMessage: (proposal) ->
    text = "#{proposal.get 'name'}"
    # text += " (Reward: #{proposal.get 'amount'})" if proposal.get('amount')?
    # score = proposal.ratings().score()
    # text += " Rating: #{score}%" unless isNaN(score)
    # text += " (awarded)" if proposal.get('awarded')?
    text

module.exports = HomeView
