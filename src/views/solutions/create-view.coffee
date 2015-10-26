{ log, p, pjson } = require 'lightsaber'

class CreateView
  constructor: (@data) ->
    @menu = {
      x: { text: "Exit", transition: 'exit', data: {proposalId: @data.proposalId} }
    }

  render: ->
    if !@data.id?
      "What is the name of your solution? ('x' to exit)"
    else if !@data.link?
      "Please enter a link to your solution. ('x' to exit)"
    else
      ''

module.exports = CreateView
