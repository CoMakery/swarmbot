{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class CreateView extends ZorkView
  constructor: (@data)->
    @menu = {}
    @menu.x = { transition: 'exit', data: {proposalId: @data.proposalId} }


  render: ->
    if !@data.name?
      @question "What is the name of your solution? ('x' to exit)"
    else if !@data.link?
      @question "Please enter a link to your solution. ('x' to exit)"

module.exports = CreateView
