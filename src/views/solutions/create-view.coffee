{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class CreateView extends ZorkView
  constructor: (@data) ->
    @menu = {}
    @menu[0] = { text: "Back", transition: 'exit', data: {proposalId: @data.proposalId} }


  render: ->
    if !@data.name?
      @question "What is the name of your solution? ('b' to go back)"
    else if !@data.link?
      @question "Please enter a link to your solution. ('b' to go back)"
    else
      ''

module.exports = CreateView
