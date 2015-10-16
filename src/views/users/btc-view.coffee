{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class BtcView extends ZorkView
  constructor: (@data, @error) ->
    i = 1
    @menu = {}
    @menu.x = { text: "Exit", transition: 'exit' }

  render: ->
    str = ""
    str += "'#{@data.address}' is an invalid bitcoin address.\n" if @error?

    str += "Please enter the bitcoin address you wish to use. (#{@renderMenu()})"
    str

module.exports = BtcView
