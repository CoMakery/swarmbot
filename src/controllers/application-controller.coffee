{ p } = require 'lightsaber'
User = require '../models/user'
Promise = require 'bluebird'
DCO = require '../models/dco'

class ApplicationController
  currentUser: ->
    activeUser = @msg.robot.whose @msg
    # User.find activeUser
    new User id: activeUser

  getCommunity: Promise.promisify (fn)->
    if @community?
      dco = DCO.find(@community)
      fn(null, dco)
      return

    user = @currentUser()
    user.fetch()
    user.once 'sync', (user)->
      @community = user.get('current_community')
      if @community?
        dco = DCO.find(@community)
        fn(null, dco)
      else
        fn("No community found")
    user.once 'error', (user)->
      p "Error synchronizing User state", arguments
      throw new Error("Error synchronizing user state", arguments)


module.exports = ApplicationController
