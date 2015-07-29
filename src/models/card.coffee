class Card

  @robot = null

  @store: ->
    throw new Error('robot is not set up') unless @robot
    @robot.brain.data.cards or= {}

  @defaultName: ->
    '__default__'

  @all: ->    
    cards = []
    for key, cardData of @store()
      continue if key is @defaultName()
      cards.push new Card(cardData.name, cardData.units)
    cards

  @getDefault: (members = [])->
    @create(@defaultName(), members) unless @exists @defaultName()
    @get @defaultName()

  @count: ->
    Object.keys(@store()).length

  @get: (name)->
    return null unless @exists name
    cardData = @store()[name]
    new Card(cardData.name, "0", cardData.members)

  @getOrDefault: (cardName)->
    if cardName then @get(cardName) else @getDefault()

  @exists: (name)->
    name of @store()

  @create: (name, units)->
    return false if @exists name
    @store()[name] =
      name: name
      units: units
    new Card(name, units)

  constructor: (name, units)->
    @name = name or Card.defaultName()
    @units = size or "0"

  destroy: ->
    delete Card.store()[@name]

  isDefault: ->
    @name is Card.defaultName()

  label: ->
    if @isDefault()
      'card'
    else
      "`#{@name}` card"

module.exports = Card
