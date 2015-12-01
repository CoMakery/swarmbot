{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-state-controller'
DcoCollection = require '../collections/dco-collection'
IndexView = require '../views/dcos/index'
CreateView = require '../views/dcos/create-view'
DCO = require '../models/dco.coffee'

class DcosStateController extends ApplicationController
  # choose DCO
  index: ->
    DcoCollection.all().then (dcos) =>
      view = new IndexView dcos
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
        return @saveDco data

    @currentUser.set 'stateData', data
    .then =>
      @render new CreateView data

  saveDco: (data) ->
    new DCO
      name: data.name
      project_statement: data.description
      project_owner: @currentUser.key()
    .save()
    .then (dco) =>
      dco.issueAsset amount: DCO::INITIAL_PROJECT_COINS
      @sendInfo "Project created"
      @currentUser.set 'current_dco', dco.key()
    .then =>
      @execute transition: 'showDco'

module.exports = DcosStateController
