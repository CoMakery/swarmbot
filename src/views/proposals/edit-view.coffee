{ log, p, pjson } = require 'lightsaber'

class EditView
  constructor: ->
    @menu = {
      x: { text: "Exit", transition: 'exit' }
    }

  render: ->
    "Enter the bounty amount ('x' to exit)"

module.exports = EditView
