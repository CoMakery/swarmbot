{ log, p, pjson } = require 'lightsaber'
{ compact } = require 'lodash'
ZorkView = require '../zork-view'

class CreateView extends ZorkView

  constructor: (@data, {@errorMessage})->
    @menu = {}
    @menu.x = { text: "back", transition: 'exit' }

  render: ->
    errorAttachment = @warning(@errorMessage) if @errorMessage?

    questionAttachment = \
      if not @data.name?
        @question "What is the name of this project? ('x' to exit)"
      else if not @data.description?
        @question "Please enter a short description of this project."
      else if not @data.initialCoins?
        @question "How many project coins should we create for this project?
          This cannot be changed.
          (Enter 'ok' for the default of 100 million project coins)
        "
      else if not @data.tasksUrl?
        @question "Please enter a link to your project tasks."
      else if not @data.imageUrl or @data.ignoreImage
        @question "Please enter an image URL for this project (enter 'n' for none)"
      else
        ''

    compact [
      errorAttachment
      questionAttachment
    ]

module.exports = CreateView
