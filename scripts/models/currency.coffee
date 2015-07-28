class Currency

  @robot = null

  @store: ->
    throw new Error('robot is not set up') unless @robot
    @robot.brain.data.currencys or= {}

  @defaultName: ->
    '__default__'

  @all: ->
    currencys = []
    for key, currencyData of @store()
      continue if key is @defaultName()
      currencys.push new Currency(currencyData.name, currencyData.units)
    currencys

  @getDefault: (members = [])->
    @create(@defaultName(), members) unless @exists @defaultName()
    @get @defaultName()

  @count: ->
    Object.keys(@store()).length

  @get: (name)->
    return null unless @exists name
    currencyData = @store()[name]
    new Currency(currencyData.name, "0", currencyData.members)

  @getOrDefault: (currencyName)->
    if currencyName then @get(currencyName) else @getDefault()

  @exists: (name)->
    name of @store()

  @create: (name, units)->
    return false if @exists name
    @store()[name] =
      name: name
      units: units
    new Currency(name, units)

  constructor: (name, units)->
    @name = name or Currency.defaultName()
    @units = size or "0"

  destroy: ->
    delete Currency.store()[@name]

  isDefault: ->
    @name is Currency.defaultName()

  label: ->
    if @isDefault()
      'currency'
    else
      "`#{@name}` currency"

module.exports = Currency
