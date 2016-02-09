{ log, p, pjson } = require 'lightsaber'
{ clone, isEmpty, map } = require 'lodash'
ZorkView = require '../zork-view'
Verbiage = require '../verbiage'

class IndexView extends ZorkView

  constructor: ({@projects, @currentUser, @userBalances, @coluError})->
    i = 0
    @projectItems = []
    for project in @projects
      @projectItems.push [@letters[i++], @projectMenuItem project]

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
    @actions[i++] = {
      text: "suggest a swarmbot improvement"
      command: 'suggest'
    }

    @menu = clone @actions
    for [key, menuItem] in @projectItems
      @menu[key.toLowerCase()] = menuItem if key?


  projectMenuItem: (project)->
    {
      text: project.get 'name'
      data: {id: project.key(), name: project.get('name')}
      command: 'setProjectTo'
    }

  render: ->
    message = []
    if not @currentUser.get('hasInteracted')
      message.push {
        pretext: "Welcome friend!
          I am here to help you contribute to projects and receive project coins.
          Project coins track your share of a project using a trusty blockchain."
      }
      message.push {
        pretext: Verbiage.NEW_BTC_AND_WHY
      }
    if isEmpty(@projectItems) or not @currentUser.get('hasInteracted')
      message.push {
        title: "Let's get started!  Type 1, hit enter, and create your first project."
      }
      @currentUser.set 'hasInteracted', true

    if isEmpty @projectItems
      projectsItems = "There are currently no projects."
    else
      message.push {
        pretext: "Contribute to projects and receive project coins!"
      }
      projectsItems = @renderOrderedMenuItems @projectItems

    hostPercentageMessage = if process.env.HOST_PERCENTAGE and process.env.HOST_NAME
      "\n#{process.env.HOST_PERCENTAGE}% of project coins
        will be distributed to #{process.env.HOST_NAME}"

    message.push {
      fields: [
        {
          title: "Choose a Project"
          value: projectsItems
          short: true
        }
        {
          title: "Your Project Coins"
          value: "#{@balances()}#{hostPercentageMessage}"
          short: true
        }
        { short: true }
        {
          title: "Actions"
          value: @renderMenuItems @actions
          short: true
        }
      ]
    }

    message

  balances: ->
    balances = for userBalance in @userBalances
      "#{userBalance.name} #{App.COIN} #{userBalance.balance}"
    balances = balances.join("\n") or "No Coins yet"
    balances += "\nbitcoin address: #{@bitcoinAddress @currentUser.get 'btcAddress'}"

    if @coluError?
      balances += "\n#{@coluError}"

    balances

module.exports = IndexView
