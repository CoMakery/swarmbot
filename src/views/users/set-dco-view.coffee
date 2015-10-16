{ log, p, pjson } = require 'lightsaber'

class SetDcoView

  constructor: (dcos) ->
    i = 1
    @menu = {}
    for dco in dcos.all()
      @menu[i++] = @dcoMenuItem dco
    @menu.x = { text: "Exit", transition: 'exit' }

  dcoMenuItem: (dco) ->
    id = dco.get 'id'
    {
      text: id
      data: { id }
      command: 'setDcoTo'
      # transition: 'exit'
    }

  render: ->
    lines = for i, menuItem of @menu
      "#{i}: #{menuItem.text}"
    """
    *Set Current Community*
    #{lines.join("\n")}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

module.exports = SetDcoView
