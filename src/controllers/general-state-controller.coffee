{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './state-application-controller'
MoreCommandsView = require '../views/general/more-commands-view'

class GeneralStateController extends ApplicationController

  # map of state name -> controller action
  stateActions:
    moreCommands: 'moreCommands'

  moreCommands: ->
    view = new MoreCommandsView
    @currentUser.set 'menu', view.menu
    @msg.send view.render()

module.exports = GeneralStateController
