{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
{ assign } = require 'lodash'
swarmbot = require './swarmbot'

class FirebaseModel

  @find: (name, options={}) ->
    new @ {name}, options
      .fetchIfNeeded()

  @findBy: Promise.promisify (attrName, attrValue, cb) ->
    swarmbot.firebase().child(@::urlRoot)
      .orderByChild(attrName)
      .equalTo(attrValue)
      .limitToFirst(1)
      .once 'value', (snapshot)=>
        if snapshot.val()
          key = Object.keys(snapshot.val())[0]
          cb(null, new @({}, snapshot: snapshot.child(key)))
        else
          cb(new Promise.OperationalError("Cannot find a model with #{attrName} equal to #{attrValue}."))
    , cb # error


  constructor: (@attributes={}, options={}) ->
    @hasParent = @hasParent || false
    @parent = options.parent

    throw new Error "urlRoot must be set." unless @urlRoot
    throw new Error "This model requires a parent." if @hasParent && !@parent
    throw new Error "please pass name, not id in attributes" if @attributes.id?
    throw new Error "@attributes must contain 'name'; got #{pjson @attributes}" if !@attributes.name? and !options.snapshot?

    @snapshot = if options.snapshot
      options.snapshot
    else if @parent?.snapshot?
      @parent.snapshot.child(@urlRoot).child(@key())
    @parseSnapshot() if @snapshot?

  # Firebase-safe key
  # Converts illegal characters .#$[] to -
  # if .name is  'strange .#$[] chars!'
  # .key will be 'strange ----- chars!'
  key: ->
    if not @attributes.name?
      throw new Error "@attributes.name not found for #{pjson @}"
      @fetch().then => throw new Error "before fetching, @attributes.name was not found for #{pjson @}"
    key = @attributes.name.replace(/[.#$\[\]]/g, '-')

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
