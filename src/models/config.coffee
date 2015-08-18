class Config
  @adminList: ->
    process.env.HUBOT_TEAM_ADMIN

  @admins: ->
    if @adminList()
      @adminList().split ','
    else
      []

  @isAdmin: (user)->
    user in @admins()

module.exports = Config
