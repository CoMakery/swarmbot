{ log, p, pjson } = require 'lightsaber'

class CreateView
  constructor: (@data) ->
    @menu = {
      x: { text: "Exit", transition: 'exit' }
    }

  render: ->
    if !@data.id?
      "What is the name of your proposal? ('x' to exit)"
    else if !@data.description?
      "Please enter a brief description of your proposal. ('x' to exit)"
    else
      "[create a proposal now]"

module.exports = CreateView
