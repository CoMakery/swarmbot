{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class CreateView extends ZorkView
  constructor: (@data) ->
    @menu = {}
    @menu[0] = { text: "back", transition: 'exit' }

  render: ->
    if !@data.name?
      @question "What is the name of your proposal? ('0' to go back)"
    else if !@data.description?
      @question "Please enter a brief description of your proposal. ('0' to go back)"
    else if !@data.imageUrl?
      @question 'Please enter an image URL for your proposal (enter "n" for none)'
    else
      ''

module.exports = CreateView
