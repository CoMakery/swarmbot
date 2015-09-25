{log, p, pjson} = require 'lightsaber'
Promise = require 'bluebird'
swarmbot = require './swarmbot'
{ assign } = require 'lodash'

class FirebaseModel
  constructor: (@attributes={}, options={}) ->
    @hasParent = @hasParent || false
    @parent = options.parent

  firebase: ->
    firebase = if @hasParent
      @parent.firebase().child(@urlRoot).child(@get('id'))
    else
      swarmbot.firebase().child(@urlRoot).child(@get('id'))

  get: (attr) ->
    @attributes[attr]

  set: (attr, val) ->
    @attributes[attr] = val
    @save()

  fetch: Promise.promisify (cb) ->
    @firebase().once 'value', (@snapshot) =>
      assign @attributes, @snapshot.val()
      cb(null, @)

  save: ->
    @firebase().update @attributes

  exists: ->
    @snapshot.exists()

module.exports = FirebaseModel
