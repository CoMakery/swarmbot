{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class ShowView extends ZorkView
  constructor: (@user)->
    i = 0
    @menu = {}

    @menu[i++] = { text: "back", transition: 'exit' }
    @menu[i++] = { text: "set bitcoin address", transition: 'setBtc' }
    @menu[i++] = { text: "my balance", command: 'balance' }

  render: ->
    [
      @userText(@user)
      @action @renderMenu()
    ]

  userText: (user)->
    if user?
      @body """
      Real name: #{(user.get('realName') ? '[not set]')}
      Username: #{user.get('slackUsername')}
      Current project: #{user.get('currentProject')}
      Bitcoin address: #{(user.get('btcAddress') ? '[not set]')}
      """
    else
      @warning "User not found"

module.exports = ShowView
