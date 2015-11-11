{ log, p, pjson } = require 'lightsaber'

class CreateView
  constructor: (@data) ->
    @menu = {
      b: { text: "Back", transition: 'exit', data: {proposalId: @data.proposalId} }
    }

  render: ->
    if !@data.name?
      "What is the name of your solution? ('b' to go back)"
    else if !@data.link?
      "Please enter a link to your solution. ('b' to go back)"
    else
      ''

module.exports = CreateView
