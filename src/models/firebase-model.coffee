{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
{ assign } = require 'lodash'
swarmbot = require './swarmbot'

class FirebaseModel

  @find: (name, options={}) ->
    new @ {name}, options
      .fetchIfNeeded()

  constructor: (@attributes={}, options={}) ->
    throw new Error "urlRoot must be set." unless @urlRoot
    throw new Error "please pass name, not id in attributes" if @attributes.id?
    throw new Error "@attributes must contain 'name'; got #{pjson @attributes}" if !@attributes.name? and !options.snapshot?
    @hasParent = @hasParent || false
    @parent = options.parent
    @snapshot = if options.snapshot
      options.snapshot
    else if @parent?.snapshot?
      @parent.snapshot.child(@urlRoot).child(@key())
    @parseSnapshot() if @snapshot?

  # Firebase-safe key
  # if .name is 'strange .#$[] chars!'
  # .key will be 'strange-chars!'
  key: ->
    @attributes.name.replace(/[-\s.#$\[\]]+/g, '-').replace(/(^-+|-+$)/g, '')

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
