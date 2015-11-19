{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class EditView extends ZorkView
  constructor: (@data) ->
    @menu = {
      b: { text: "Back", transition: 'exit', data: {proposalId: @data.proposalId} }
    }

  render: ->
    "Enter the bounty amount ('b' to go back)"

module.exports = EditView
