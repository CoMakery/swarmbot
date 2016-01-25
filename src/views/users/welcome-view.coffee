{ log, p, pjson } = require 'lightsaber'
ZorkView = require '../zork-view'
Verbiage = require '../verbiage'

class WelcomeView extends ZorkView
  constructor: ({@currentUser})->

  render: ->
    [
      @body "
        Hi @#{@currentUser.get('slackUsername')}!  My name is Swarmbot,
        and I'm here to help you
        create projects for things that you want to collaborate on,
        and assign rewards to people who do them!
        "
      @body "
        Below is a list of projects others have already created
        that you may like to collaborate on...
        "
      @body Verbiage.NEW_BTC_AND_WHY
    ]

module.exports = WelcomeView
