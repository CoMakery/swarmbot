{ compact } = require 'lodash'
{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class ShowView extends ZorkView
  constructor: ({@project, @currentUser, @userBalance})->
    @orderedMenu = []
    @menu = {}

    i = 1
    @menu[i++] = { text: "all projects", transition: 'setProject' }
    @menu[i++] = { text: "show awards list", command: 'rewardsList' }
    @menu[i++] = { text: "show project ownership", command: 'capTable' }
    # @menu[i++] = { text: "suggest a swarmbot improvement", transition: 'suggest' }

    # if admin/progenitor
    @menu[i++] = { text: "create an award level", transition: 'create' }
    @menu[i++] = { text: "send an award", transition: 'sendReward', data: {projectId: @project.key()} }

  render: ->
    headline = if @project.rewardTypes().isEmpty() then 'No awards' else 'Awards'
    headline += " in #{@project.get 'name'}"
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
        title: @project.get('name').toUpperCase()
        text: @project.get 'project_statement'
        thumb_url: @project.get 'imageUrl'
      }
      (
        title: 'See Project Tasks'
        title_link: @project.get 'tasksUrl'
      ) if @project.get 'tasksUrl'
      {
        fields: [
          {
            title: 'Possible Awards'
            value: if @project.rewardTypes().isEmpty()
                "There are no awards in this project."
              else
                @project.rewardTypes().map (rewardType)->
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