{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class CreateView extends ZorkView
  constructor: (@data) ->
    @menu = {
      b: { text: "Back", transition: 'exit' }
    }

  render: ->
    if !@data.name?
      @question "What is the name of your proposal? ('b' to go back)"
    else if !@data.description?
      @question "Please enter a brief description of your proposal. ('b' to go back)"
    else if !@data.imageUrl?
      @question 'Please enter an image URL for your proposal (enter "n" for none)'
    else
      ''

module.exports = CreateView
