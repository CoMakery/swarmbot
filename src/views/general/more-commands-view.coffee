{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class MoreCommandsView extends ZorkView
  constructor: ->
    i = 1
    @menu = {}
    @menu[i++] = { text: "Set community", transition: 'setDco' }
    @menu[i++] = { text: "My account", transition: 'myAccount' }
    @menu.x    = { text: "Exit", transition: 'exit' }

  render: ->
    """
    *More Commands*
    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

module.exports = MoreCommandsView
