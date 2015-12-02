{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class EditView extends ZorkView
  constructor: (@data)->
    @menu = {}
    @menu[0] = { text: "Back", transition: 'exit', data: {proposalId: @data.proposalId} }

  render: ->
    @question "Enter the bounty amount ('0' to go back)"

module.exports = EditView
