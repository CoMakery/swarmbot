{ log, p, pjson } = require 'lightsaber'
{ compact } = require 'lodash'
ZorkView = require '../zork-view'

class CreateView extends ZorkView
  constructor: ({@data, @errorMessage})->
    @menu = {}
    @menu[0] = { text: "back", transition: 'exit' }

  render: ->
    errorAttachment = @warning(@errorMessage) if @errorMessage?

    questionAttachment = \
      if !@data.name?
        @question "What is the name of your task? ('0' to go back)"
      else if !@data.description?
        @question "Please enter a brief description of your task. ('0' to go back)"
      else if !@data.imageUrl?
        @question "Please enter an image URL for your task (enter 'n' for none)"
      else
        ''

    compact [
      errorAttachment
      questionAttachment
    ]

module.exports = CreateView
