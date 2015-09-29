{ assign, partition, sortByOrder, forEach, map } = require 'lodash'

class FirebaseCollection
  constructor: (modelsOrSnapshot, options={})->
    throw new Error("Collection requires a model.") unless @model?

    @parent = options.parent
    if modelsOrSnapshot instanceof Array
      @models = modelsOrSnapshot
    else
      @snapshot = modelsOrSnapshot
      @models = for id, data of @snapshot.val()
        new @model assign(data, id: id), { parent: @parent }

  fetch: ->
    @map (model) -> model.fetch()

  isEmpty: ->
    length = if @snapshot? then @snapshot.numChildren() else @models.length
    (length == 0)

  each: (cb)->
    forEach @models, cb

  map: (cb)->
    map @models, cb

  count: ->
    @models.length

module.exports = FirebaseCollection
