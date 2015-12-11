{ compact } = require 'lodash'
{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class ShowView extends ZorkView
  constructor: ({@dco, @currentUser, @userBalance})->
    @orderedMenu = []
    @menu = {}

    i = 1
    @menu[i++] = { text: "all projects", transition: 'setDco' }
    @menu[i++] = { text: "show awards list", command: 'rewardsList' }
    @menu[i++] = { text: "show project ownership", command: 'capTable' }
    # @menu[i++] = { text: "suggest a swarmbot improvement", transition: 'suggest' }

    # if admin/progenitor
    @menu[i++] = { text: "create an award level", transition: 'create' }
    @menu[i++] = { text: "send an award", transition: 'sendReward', data: {dcoId: @dco.key()} }

  render: ->
    headline = if @dco.rewardTypes().isEmpty() then 'No awards' else 'Awards'
    headline += " in #{@dco.get 'name'}"
    """
    [Home] #{@bold headline}
    #{@renderMenu()}

    Note: awards are granted by project admins at their discretion.
    To take an action, simply enter the number or letter at the beginning of the line.
    """

    if @userBalance.balance
      balance = "#{App.COIN} #{@userBalance.balance}/#{@userBalance.totalCoins}"
    else
      balance = "No Coins yet"

    balance += "\nbitcoin address: " + @bitcoinAddress()
    compact [
      {
        title: @dco.get('name').toUpperCase()
        text: @dco.get 'project_statement'
        thumb_url: @dco.get 'imageUrl'
      }
      (
        title: 'See Project Tasks'
        title_link: @dco.get 'tasksUrl'
      ) if @dco.get 'tasksUrl'
      {
        fields: [
          {
            title: 'Possible Awards'
            value: if @dco.rewardTypes().isEmpty()
                "There are no awards in this project."
              else
                @dco.rewardTypes().map (rewardType)->
                  "#{rewardType.get 'name'} (#{rewardType.get('suggestedAmount')})"
                .join("\n")
            short: true
          }
          {
            title: "Your Project Coins"
            value: balance
            short: true
          }
          { short: true }
          {
            title: 'Actions'
            value: @renderMenu()
            short: true
          }
        ]
      }
    ]

  rewardTypeMenuItem: (rewardType)->
    {
      text: rewardType.get('name').toLowerCase()
      data: { rewardTypeId: rewardType.key() }
      transition: 'show'
    }

module.exports = ShowView
