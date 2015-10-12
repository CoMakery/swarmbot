{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
{ assign } = require 'lodash'
swarmbot = require './swarmbot'

class FirebaseModel

  @find: (id, options={}) ->
    new @(id: id, options)
      .fetch()

  constructor: (@attributes={}, options={}) ->
    @hasParent = @hasParent || false
    @parent = options.parent
    @snapshot = options.snapshot
    @parseSnapshot() if @snapshot?

  firebase: ->
    swarmbot.firebase().child(@firebasePath())

  firebasePath: ->
    parentPath = if @hasParent then @parent.firebasePath() else ''
    [ parentPath, @urlRoot, @get('id') ].join '/'

  get: (attr) ->
    @attributes[attr]

  set: (attr, val) ->
    @attributes[attr] = val
    @save()

  fetch: Promise.promisify (cb) ->
    throw new Error "No id attribute is set, cannot fetch" unless @.get('id')
    @firebase().once 'value', (@snapshot) =>
      @parseSnapshot()
      cb(null, @)
    , cb # failure callback

  fetchIfNeeded: ->
    if @snapshot?
      Promise.resolve(@)
    else
      @fetch()

  # TODO: should return the model instance
  save: Promise.promisify (cb)->
    @firebase().update @attributes, cb

  exists: ->
    @snapshot.exists()

  parseSnapshot: ->
    assign @attributes, @snapshot.val()
    @

module.exports = FirebaseModel
