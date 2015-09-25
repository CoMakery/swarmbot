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
    , cb # failure callback

  save: Promise.promisify (cb)->
    @firebase().update @attributes, cb

  exists: ->
    @snapshot.exists()

module.exports = FirebaseModel
