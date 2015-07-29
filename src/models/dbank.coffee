class DBank

  @robot = null

  @store: ->
    throw new Error('robot is not set up') unless @robot
    @robot.brain.data.banks or= {}

  @defaultName: ->
    '__default__'

  @all: ->
    banks = []
    for key, bankData of @store()
      continue if key is @defaultName()
      banks.push new DBank(bankData.name, bankData.units)
    banks

  @getDefault: (members = [])->
    @create(@defaultName(), members) unless @exists @defaultName()
    @get @defaultName()

  @count: ->
    Object.keys(@store()).length

  @get: (name)->
    return null unless @exists name
    bankData = @store()[name]
    new DBank(bankData.name, "0", bankData.members)

  @getOrDefault: (bankName)->
    if bankName then @get(bankName) else @getDefault()

  @exists: (name)->
    name of @store()

  @create: (name, units)->
    return false if @exists name
    @store()[name] =
      name: name
      units: units
    new DBank(name, units)

  constructor: (name, units)->
    @name = name or DBank.defaultName()
    @units = size or "0"

  destroy: ->
    delete DBank.store()[@name]

  isDefault: ->
    @name is DBank.defaultName()

  label: ->
    if @isDefault()
      'bank'
    else
      "`#{@name}` bank"

module.exports = DBank
