{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
swarmbot = require './swarmbot'
{ assign } = require 'lodash'

class FirebaseModel
  constructor: (attributesOrSnapshot={}, options={}) ->
    @attributes = attributesOrSnapshot
    @hasParent = @hasParent || false
    @parent = options.parent

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
    @firebase().once 'value', (@snapshot) =>
      @parseSnapshot()
      cb(null, @)
    , cb # failure callback

  save: Promise.promisify (cb)->
    @firebase().update @attributes, cb

  exists: ->
    @snapshot.exists()

  parseSnapshot: ->
    assign @attributes, @snapshot.val()

module.exports = FirebaseModel
