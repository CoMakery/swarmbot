{ log, p, pjson } = require 'lightsaber'

class CreateView
  constructor: (@data) ->
    @menu = {
      b: { text: "Back", transition: 'exit' }
    }

  render: ->
    if !@data.id?
      "What is the name of your proposal? ('b' to go back)"
    else if !@data.description?
      "Please enter a brief description of your proposal. ('b' to go back)"
    else if !@data.imageUrl?
      'Please enter an image URL for your proposal (enter "n" for none)'
    else
      ''

module.exports = CreateView
