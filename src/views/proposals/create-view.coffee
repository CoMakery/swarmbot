{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class CreateView extends ZorkView
  constructor: (@data) ->
    @menu = {
      b: { text: "Back", transition: 'exit' }
    }

  render: ->
    message = if !@data.name?
      "What is the name of your proposal? ('b' to go back)"
    else if !@data.description?
      "Please enter a brief description of your proposal. ('b' to go back)"
    else if !@data.imageUrl?
      'Please enter an image URL for your proposal (enter "n" for none)'
    else
      ''
    @question message if message

module.exports = CreateView
