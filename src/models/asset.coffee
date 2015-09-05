class Asset

  @robot = null

  @store: ->
    throw new Error('robot is not set up') unless @robot
    robot.brain.get 'assets'

  @defaultName: ->
    '__default__'

  @all: ->
    assets = []
    for key, assetData of @store()
      continue if key is @defaultName()
      assets.push new Asset(assetData.name, assetData.size, assetData.members)
    assets

  @getDefault: (members = [])->
    @create(@defaultName(), members) unless @exists @defaultName()
    @get @defaultName()

  @count: ->
    Object.keys(@store()).length

  @get: (name)->
    return null unless @exists name
    assetData = @store()[name]
    new Asset(assetData.name, "0", assetData.members)

  @getOrDefault: (assetName)->
    if assetName then @get(assetName) else @getDefault()

  @exists: (name)->
    name of @store()

  @create: (name, size, balance)->
    return false if @exists name
    @store()[name] =
      name: name
      size: size
      balance: balance
    new Asset(name, size, members)

  @updateAssetBalance: (name, change)->
    return false if @exists name
    oldBalance = (@store()[name] || {}).balance
    @store()[name] =
      name: name
      balance: oldBalance + change
    true

  constructor: (name, size, @members = [])->
    @name = name or Asset.defaultName()
    @size = size or "0"
    # assets = robot.brain.get 'assets'
    # var messageListRef = new Firebase('https://samplechat.firebaseio-demo.com/message_list');
    # assets[name] = { size, @members }
    # robot.brain.set 'assets', assets



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
    Asset.store()[@name].members = []
    @members = []

  destroy: ->
    delete Asset.store()[@name]

  isDefault: ->
    @name is Asset.defaultName()

  label: ->
    if @isDefault()
      'asset'
    else
      "`#{@name}` asset"

module.exports = Asset
