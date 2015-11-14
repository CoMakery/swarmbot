{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class ShowView extends ZorkView
  constructor: (@user) ->
    i = 1
    @menu = {}

    @menu[i++] = { text: "Set bitcoin address", transition: 'setBtc' }
    @menu[i++] = { text: "My balance", command: 'balance' }
    @menu.b = { text: "Back", transition: 'exit' }

  render: ->
    @userText(@user) + "\n\n" + @renderMenu()

  userText: (user)->
    if user?
      """
      Real name: #{(user.get('real_name') ? '[not set]')}
      Username: #{user.get('slack_username')}
      Current community: #{user.get('current_dco')}
      Bitcoin address: #{(user.get('btc_address') ? '[not set]')}
      """
    else
      "User not found"

module.exports = ShowView
