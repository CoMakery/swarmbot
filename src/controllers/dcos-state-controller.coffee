{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-state-controller'
DcoCollection = require '../collections/dco-collection'
SetDcoView = require '../views/dcos/set-dco-view'

class DcosStateController extends ApplicationController
  # choose DCO
  index: ->
    DcoCollection.all().then (dcos) =>
      view = new SetDcoView dcos
      @currentUser.set 'menu', view.menu
      view.render()

  # set DCO
  setDcoTo: (data)->
    @currentUser.setDcoTo(data.id).then =>
      @currentUser.exit()
      @redirect "Project set to #{data.name}"


module.exports = DcosStateController
