{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'

class WelcomeView extends ZorkView
  constructor: ({@currentUser})->

  render: ->
    [
      @body "
        Hi @#{@currentUser.get('slack_username')}!  My name is Swarmbot, and I'm here to help you
        create projects for things that you want to collaborate on,
        and assign rewards to people who do them!
        "
      @body """
        You can create a new project by typing:
        `create project <My Awesome Project>`
        """
      @body "
        Here is a list of projects others have already created
        that you may like to collaborate on...
        "
    ]

module.exports = WelcomeView
