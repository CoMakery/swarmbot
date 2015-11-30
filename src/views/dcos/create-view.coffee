{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class CreateView extends ZorkView

  constructor: (@data) ->
    @menu = {}
    @menu[0] = { text: "back", transition: 'exit' }

  render: ->
    if not @data.name?
      @question "What is the name of this project? (0: back)"
    else if not @data.description?
      @question "Please enter a short description of this project."
    else
      ''

module.exports = CreateView
