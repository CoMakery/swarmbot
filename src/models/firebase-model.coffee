{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
{ assign } = require 'lodash'
swarmbot = require './swarmbot'

class FirebaseModel

  @find: (id, options={}) ->
    new @(id: id, options)
      .fetchIfNeeded()

  constructor: (@attributes={}, options={}) ->
    throw new Error "urlRoot must be set." unless @urlRoot
    throw new Error "please pass name, not id in attributes" if @attributes.id?
    throw new Error "please pass name in attributes" unless @attributes.name?
    @hasParent = @hasParent || false
    @parent = options.parent
    @snapshot = options.snapshot
    if @parent?.snapshot? and @attributes.id
      @snapshot ?= @parent.snapshot.child(@urlRoot).child(@key())

    @parseSnapshot() if @snapshot?

  key: -> @attributes.name.replace(/[\s.#$\[\]]+/g, '-').replace(/(^-+|-+$)/g, '')

  firebase: ->
    swarmbot.firebase().child(@firebasePath())

  firebasePath: ->
    parentPath = if @hasParent then @parent.firebasePath() else ''
    [ parentPath, @urlRoot, @key() ].join '/'

  get: (attr) ->
    @attributes[attr]

  set: (attr, val) ->
    @attributes[attr] = val
    @save()

  fetch: Promise.promisify (cb) ->
    throw new Error "No name attribute is set, cannot fetch" unless @get('name')
    @firebase().once 'value', (@snapshot) =>
      @parseSnapshot()
      cb(null, @)
    , cb # failure callback

  fetchIfNeeded: ->
    if @snapshot?
      Promise.resolve(@)
    else
      @fetch()

  save: Promise.promisify (cb) ->
    @firebase().update @attributes, (error)=> cb error, @

  exists: ->
    @snapshot.exists()

  parseSnapshot: ->
    assign @attributes, @snapshot.val()
    @

module.exports = FirebaseModel
