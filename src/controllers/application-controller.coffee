User = require '../models/user'

class ApplicationController
  currentUser: ->
    activeUser = @msg.robot.whose @msg
    # User.find activeUser
    new User id: activeUser

module.exports = ApplicationController
