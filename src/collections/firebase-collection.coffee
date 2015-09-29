{log, p, pjson} = require 'lightsaber'
{ assign, partition, sortByOrder, forEach, map, filter } = require 'lodash'

class FirebaseCollection
  constructor: (modelsOrSnapshot, options={})->
    throw new Error("Collection requires a model.") unless @model?

    @parent = options.parent
    if modelsOrSnapshot instanceof Array
      @models = modelsOrSnapshot
    else
      @snapshot = modelsOrSnapshot
      @models = for id, data of @snapshot.val()
        new @model assign(data, id: id), { parent: @parent, snapshot: @snapshot.child(id) }

  fetch: ->
    @map (model) -> model.fetch()

  # XXX: Breaks if you edit the @models manually and not the @snapshot. (e.g. @filter())
  # Maybe just use the @models instead of numChildren
  isEmpty: ->
    length = if @snapshot? then @snapshot.numChildren() else @models.length
    (length == 0)

  each: (cb)->
    forEach @models, cb

  map: (cb)->
    map @models, cb

  # TODO: Should this be destructive / edit in-place, or return a new collection?
  filter: (cb) ->
    @models = filter @models, cb

  size: ->
    @models.length

module.exports = FirebaseCollection
