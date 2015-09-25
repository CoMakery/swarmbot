{ log, p, pjson } = require 'lightsaber'
User = require '../models/user'
Promise = require 'bluebird'
DCO = require '../models/dco'

class ApplicationController
  currentUser: ->
    activeUserId = @msg.robot.whose @msg
    # User.find activeUser
    new User id: activeUserId

  getDco: ->
    if @community?
      Promise.resolve(DCO.find(@community)).bind(@)
    else
      @currentUser().fetch().bind(@).then (user) ->
        @community = user.get('current_dco')
        if @community?
          DCO.find(@community)
        else
          Promise.reject(Promise.OperationalError("No community found"))


module.exports = ApplicationController
