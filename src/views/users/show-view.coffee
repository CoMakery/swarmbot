{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class ShowView extends ZorkView
  constructor: (@user) ->
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
      Real name: #{(user.get('real_name') ? '[not set]')}
      Username: #{user.get('slack_username')}
      Current project: #{user.get('current_dco')}
      Bitcoin address: #{(user.get('btc_address') ? '[not set]')}
      """
    else
      @warning "User not found"

module.exports = ShowView
