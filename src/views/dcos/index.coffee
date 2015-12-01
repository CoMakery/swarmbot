debug = require('debug')('app')
{ log, p, pjson } = require 'lightsaber'
{ isEmpty, clone } = require 'lodash'
ZorkView = require '../zork-view'

class IndexView extends ZorkView

  constructor: (@dcos, @balances) ->
    i = 0
    @dcoItems = []
    for dco in @dcos.all()
      @dcoItems.push [@letters[i++], @dcoMenuItem dco]

    i = 0
    @actions = {}
    @actions[i++] = { text: "back", transition: 'exit' }
    @actions[i++] = {
      text: "create new project"
      transition: 'create'
    }

    @menu = clone @actions
    for [key, menuItem] in @dcoItems
      @menu[key.toLowerCase()] = menuItem if key?


  dcoMenuItem: (dco) ->
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

    if isEmpty @dcos.all()
      {
        color: @BODY_COLOR
        pretext: "Contribute to projects and get rewarded with project coins!"
        title: "Let's get started!  Type 1 now to create a new project."
      }
    else
      # [ {name: 'dco name', balance: 2000} ]
      [
        {
          color: @NAV_COLOR
          title: "choose your project"
        }
        {
          color: @ACTION_COLOR
          fields: [
            {
              value: @renderOrderedMenuItems @dcoItems
              short: true
            }
            {
              title: "Project Coins"
              value: "None Yet"
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
      ]

module.exports = IndexView
