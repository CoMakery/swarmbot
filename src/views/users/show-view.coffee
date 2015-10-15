{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class CreateView extends ZorkView
  constructor: (@user) ->
    i = 1
    @menu = {}

    @menu[i++] =
      text: "Set bitcoin address"
      transition: 'update'
      data: {}
    @menu.x = { text: "Exit", transition: 'exit' }

  render: ->
    @userText(@user) + "\n\n" + @renderMenu()

  userText: (user)->
    if user?
      info = [
        "Real name: " + (user.get('real_name') ? '[not set]')
        "Username: " + user.get('slack_username')
        "Current community: " + user.get('current_dco')
        "Bitcoin address: " + (user.get('btc_address') ? '[not set]')
      ].join("\n")
    else
      "User not found"


module.exports = CreateView
