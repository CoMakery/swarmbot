{ log, p, pjson } = require 'lightsaber'
{ compact } = require 'lodash'
ZorkView = require '../zork-view'

class CreateView extends ZorkView
  constructor: ({@data, @errorMessage})->
    @menu = {}
    @menu['x'] = { text: "back", transition: 'exit' }

  render: ->
    errorAttachment = @warning(@errorMessage) if @errorMessage?

    questionAttachment = \
      if !@data.name?
        @question "What is the award name? ('x' to exit)"
      else if !@data.suggestedAmount?
        @question "Enter a suggested amount for this award. ('x' to exit)"
      else
        ''

    compact [
      errorAttachment
      questionAttachment
    ]

module.exports = CreateView
