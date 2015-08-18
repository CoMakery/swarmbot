class Account

  @robot = null

  @store: ->
    throw new Error('robot is not set up') unless @robot
    @robot.brain.data.accounts or= {}

  @defaultName: ->
    '__default__'

  @all: ->
    accounts = []
    for key, accountData of @store()
      continue if key is @defaultName()
      accounts.push new Account(accountData.name, accountData.size, accountData.members)
    accounts

  @getDefault: (members = [])->
    @create(@defaultName(), members) unless @exists @defaultName()
    @get @defaultName()

  @count: ->
    Object.keys(@store()).length

  @get: (name)->
    return null unless @exists name
    accountData = @store()[name]
    new Account(accountData.name, "0", accountData.members)

  @getOrDefault: (accountName)->
    if accountName then @get(accountName) else @getDefault()

  @exists: (name)->
    name of @store()

  @create: (name, size, balance)->
    return false if @exists name
    @store()[name] =
      name: name
      size: size
      balance: balance
    new Account(name, size, members)

  @updateAccountBalance: (name, change)->
    return false if @exists name
    oldBalance = @store()[name].balance
    @store()[name] =
      name: name
      balance: oldBalance + change
    true

  constructor: (name, size, @members = [])->
    @name = name or Account.defaultName()
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
    Account.store()[@name].members = []
    @members = []

  destroy: ->
    delete Account.store()[@name]

  isDefault: ->
    @name is Account.defaultName()

  label: ->
    if @isDefault()
      'account'
    else
      "`#{@name}` account"

module.exports = Account
