class Bounty

  @robot = null

  @store: ->
    throw new Error('robot is not set up') unless @robot
    @robot.brain.data.bountys or= {}

  @defaultName: ->
    '__default__'

  @all: ->
    bountys = []
    for key, bountyData of @store()
      continue if key is @defaultName()
      bountys.push new Bounty(bountyData.name, bountyData.size, bountyData.members)
    bountys

  @getDefault: (members = [])->
    @create(@defaultName(), members) unless @exists @defaultName()
    @get @defaultName()

  @count: ->
    Object.keys(@store()).length

  @get: (name)->
    return null unless @exists name
    bountyData = @store()[name]
    new Bounty(bountyData.name, "0", bountyData.members)

  @getOrDefault: (bountyName)->
    if bountyName then @get(bountyName) else @getDefault()

  @exists: (name)->
    name of @store()

  @create: (name, size, members = [])->
    return false if @exists name
    @store()[name] =
      name: name
      size: size
      members: members
    new Bounty(name, size, members)

  constructor: (name, size, @members = [])->
    @name = name or Bounty.defaultName()
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
    Bounty.store()[@name].members = []
    @members = []

  destroy: ->
    delete Bounty.store()[@name]

  isDefault: ->
    @name is Bounty.defaultName()

  label: ->
    if @isDefault()
      'bounty'
    else
      "`#{@name}` bounty"

module.exports = Bounty
