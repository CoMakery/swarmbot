User = require '../models/user'

class ApplicationController
  currentUser: ->
    activeUser = @msg.robot.whose @msg
    User.find activeUser

module.exports = ApplicationController
