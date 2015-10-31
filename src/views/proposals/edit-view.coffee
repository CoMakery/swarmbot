{ log, p, pjson } = require 'lightsaber'

class EditView
  constructor: (@data) ->
    @menu = {
      b: { text: "Back", transition: 'exit' }
    }

  render: ->
    "Enter the bounty amount ('b' to go back)"

module.exports = EditView
