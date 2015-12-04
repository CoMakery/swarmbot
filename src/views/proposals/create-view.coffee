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
        @question "What is the award name? ('0' to go back)"
      else if !@data.suggestedAmount?
        @question "Enter a suggested amount for this award. ('0' to go back)"
      else
        ''

    compact [
      errorAttachment
      questionAttachment
    ]

module.exports = CreateView
