{log, p, pjson} = require 'lightsaber'
{ partition, sortByOrder, find, forEach, map, filter } = require 'lodash'
swarmbot = require '../models/swarmbot'

class FirebaseCollection

  @all: Promise.promisify (cb)->
    swarmbot.firebase().child(@::model::urlRoot).once 'value', (snapshot)=>
      cb null, new @(snapshot)

  constructor: (modelsOrSnapshot, options={})->
    throw new Error("Collection requires a model.") unless @model?

    @parent = options.parent
    if modelsOrSnapshot instanceof Array
      @models = modelsOrSnapshot
    else
      @snapshot = modelsOrSnapshot
      @models = for key, data of @snapshot.val()
        new @model data,
          parent: @parent,
          snapshot: @snapshot.child(key)

  all: -> @models

  get: (i)-> @models[i]

  # TODO: Fetch this collection's path once, set all the models from the snapshot.child() nodes
  fetch: ->
    Promise.all( @map (model)-> model.fetch() )
    .then => @

  # XXX: Breaks if you edit the @models manually and not the @snapshot. (e.g. @filter())
  # Maybe just use the @models instead of numChildren
  isEmpty: ->
    length = if @snapshot? then @snapshot.numChildren() else @models.length
    (length is 0)

  each: (cb)-> forEach @models, cb

  map: (cb)-> map @models, cb

  filter: (cb)-> filter @models, cb

  find: (cb)-> find @models, cb

  size: -> @models.length

  sortBy: (sortField)->
    @models = sortByOrder @models, [
        (p)-> isNaN(p.get(sortField))
        (p)-> p.get(sortField)
      ],
      ['asc', 'desc']
    @

module.exports = FirebaseCollection
