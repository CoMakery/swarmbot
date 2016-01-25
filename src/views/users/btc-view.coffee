{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'
Verbiage = require '../verbiage'

class BtcView extends ZorkView
  constructor: (@data, @error)->
    @menu =
      x:
        text: 'exit'
        transition: 'exit'

  render: ->
    response = []
    debug {@error} if @error
    response.push @warning "'#{@data.address}' is an invalid bitcoin address." if @error?
    response.push @question "Please enter the bitcoin address you wish to use.
      #{Verbiage.NEW_BTC} (#{@renderMenu()})"
    response

module.exports = BtcView
