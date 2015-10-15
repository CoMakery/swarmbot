{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './state-application-controller'
DcoCollection = require '../collections/dco-collection'
SetDcoView = require '../views/dcos/set-dco-view'

class DcosStateController extends ApplicationController

  # map of state name -> controller action
  stateActions:
    home: 'home'
    dcosSet: 'setDco'

  setDco: ->
    DcoCollection.create().then (dcos) =>
      view = new SetDcoView dcos
      @currentUser.set 'menu', view.menu
      @msg.send view.render()

  setDcoTo: ->
    if dcoId = @currentUser.get('stateData')?.id
      @currentUser.setDcoTo(dcoId).then =>
        @msg.send "Community set to #{dcoId}"
        @currentUser.exit()
        @redirect()

module.exports = DcosStateController
