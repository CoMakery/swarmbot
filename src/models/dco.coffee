class DCO

  @robot = null

  @store: ->
    throw new Error('robot is not set up') unless @robot
    @robot.brain.data.dcos or= {}

  @defaultName: ->
    '__default__'

  @all: ->
    dcos = []
    for key, dcoData of @store()
      continue if key is @defaultName()
      dcos.push new DCO(dcoData.name, dcoData.size, dcoData.members)
    dcos

  @getDefault: (members = [])->
    @create(@defaultName(), members) unless @exists @defaultName()
    @get @defaultName()

  @count: ->
    Object.keys(@store()).length

  @get: (name)->
    return null unless @exists name
    dcoData = @store()[name]
    new DCO(dcoData.name, "0", dcoData.members)

  @getOrDefault: (dcoName)->
    if dcoName then @get(dcoName) else @getDefault()

  @exists: (name)->
    name of @store()

  @create: (name, size, balance)->
    return false if @exists name
    @store()[name] =
      name: name
      size: size
      balance: balance
    new DCO(name, size, members)

  @updateDCOBalance: (name, change)->
    return false if @exists name
    oldBalance = (@store()[name] || {}).balance
    @store()[name] =
      name: name
      balance: oldBalance + change
    true

  constructor: (name, size, @members = [])->
    @name = name or DCO.defaultName()
    @size = size or "0"

  addMember: (member)->
    return false if member in @members
    @members.push member
    true

  removeMember: (member)->
    return false if member not in @members
    index = @members.indexOf(member)
    @members.splice(index, 1)
    true

  membersCount: ->
    @members.length

  clear: ->
    DCO.store()[@name].members = []
    @members = []

  destroy: ->
    delete DCO.store()[@name]

  isDefault: ->
    @name is DCO.defaultName()

  label: ->
    if @isDefault()
      'dco'
    else
      "`#{@name}` dco"

module.exports = DCO
