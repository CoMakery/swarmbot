debug = require('debug')('app')
{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-state-controller'
AdvancedCommandsView = require '../views/general/advanced-commands-view'

class GeneralStateController extends ApplicationController


  advanced: ->
    @render new AdvancedCommandsView @msg.robot

module.exports = GeneralStateController
