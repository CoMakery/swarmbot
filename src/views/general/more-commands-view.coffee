{ log, p, pjson } = require 'lightsaber'

class MoreCommandsView
  constructor: ->
    i = 1
    @menu = {}
    @menu[i++] = { text: "Set community", transition: 'setDco' }
    @menu.x    = { text: "Exit", transition: 'exit' }

  render: ->
    lines = for i, menuItem of @menu
      "#{i}: #{menuItem.text}"
    """
    *More Commands*
    #{lines.join("\n")}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

module.exports = MoreCommandsView
