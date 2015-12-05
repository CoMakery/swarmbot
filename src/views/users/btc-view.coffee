{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class BtcView extends ZorkView
  constructor: (@data, @error)->
    i = 1
    @menu = {}
    @menu.x = { text: "exit", transition: 'exit' }

  render: ->
    response = []
    p @error
    response.push @warning "'#{@data.address}' is an invalid bitcoin address." if @error?
    response.push @question "Please enter the bitcoin address you wish to use. (#{@renderMenu()})"
    response

module.exports = BtcView
