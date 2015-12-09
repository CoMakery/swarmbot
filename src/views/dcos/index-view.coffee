debug = require('debug')('app')
{ log, p, pjson } = require 'lightsaber'
{ clone, isEmpty, map } = require 'lodash'
ZorkView = require '../zork-view'

class IndexView extends ZorkView

  constructor: ({@dcos, @currentUser, @userBalances})->
    i = 0
    @dcoItems = []
    for dco in @dcos.all()
      @dcoItems.push [@letters[i++], @dcoMenuItem dco]

    i = 1
    @actions = {}
    @actions[i++] = {
      text: "create your project"
      transition: 'create'
    }
    @actions[i++] = {
      text: "set your bitcoin address"
      transition: 'setBtc'
    }

    @menu = clone @actions
    for [key, menuItem] in @dcoItems
      @menu[key.toLowerCase()] = menuItem if key?


  dcoMenuItem: (dco)->
    {
      text: dco.get 'name'
      data: {id: dco.key(), name: dco.get('name')}
      command: 'setDcoTo'
    }

  render: ->
    fallbackText = """
    *Set Current Project*
    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """


    message = []
    if isEmpty(@dcoItems) or not @currentUser.get('has_interacted')
      message.push {
        pretext: "Welcome friend! I am here to help you contribute to projects and receive project coins. Project coins track your share of a project using a trusty blockchain."
        title: "Let's get started!  Type 1, hit enter, and create your first project."
      }
      @currentUser.set 'has_interacted', true

    if isEmpty @dcoItems
      projectsItems = "There are currently no projects."
    else
      message.push {
        pretext: "Contribute to projects and receive project coins!"
      }
      projectsItems = @renderOrderedMenuItems @dcoItems

    balances = for userBalance in @userBalances
      "#{userBalance.name} :moneybag: #{userBalance.balance}"

    balances = balances.join("\n") or "No Coins yet"

    balances += "\nbitcoin address: " +
      ( @currentUser.get('btc_address') or "None" )

    message.push {
      fields: [
        {
          title: "Choose a Project"
          value: projectsItems
          short: true
        }
        {
          title: "Your Project Coins"
          value: balances
          short: true
        }
        { short: true }
        {
          title: "Actions"
          value: @renderMenuItems @actions
          short: true
        }
      ]
      fallback: fallbackText
    }

    message

module.exports = IndexView
