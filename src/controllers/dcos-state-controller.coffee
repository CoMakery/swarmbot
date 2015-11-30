{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-state-controller'
DcoCollection = require '../collections/dco-collection'
SetDcoView = require '../views/dcos/set-dco-view'
CreateView = require '../views/dcos/create-view'
DCO = require '../models/dco.coffee'

class DcosStateController extends ApplicationController
  # choose DCO
  index: ->
    DcoCollection.all().then (dcos) =>
      view = new SetDcoView dcos
      @render(view)

  # set DCO
  setDcoTo: (data)->
    @currentUser.setDcoTo(data.id).then =>
      @currentUser.exit()
      @redirect "Project set to #{data.name}"

  create: (data={}) ->
    if @input
      if not data.name
        data.name = @input
      else if not data.description
        data.description = @input

        return (new DCO name: data.name, project_statement: data.description).save()
        .then (dco) =>
          @sendInfo "Project created"
          @currentUser.set 'current_dco', dco.key()
        .then =>
          @execute transition: 'showDco'

    @currentUser.set 'stateData', data
    .then =>
      @render new CreateView data


module.exports = DcosStateController
