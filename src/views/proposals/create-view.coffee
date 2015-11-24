{ log, p, pjson } = require 'lightsaber'
{ compact } = require 'lodash'
ZorkView = require '../zork-view'

class CreateView extends ZorkView
  constructor: ({@data, @errorMessage}) ->
    @menu = {}
    @menu[0] = { text: "back", transition: 'exit' }

  render: ->

    errorAttachment = @warning(@errorMessage) if @errorMessage?
    p 111, errorAttachment

    questionAttachment = if !@data.name?
        @question "What is the name of your proposal? ('0' to go back)"
      else if !@data.description?
        @question "Please enter a brief description of your proposal. ('0' to go back)"
      else if !@data.imageUrl?
        @question 'Please enter an image URL for your proposal (enter "n" for none)'
      else
        ''

    r = compact [
      errorAttachment
      questionAttachment
    ]
    p 222, r
    r

module.exports = CreateView
