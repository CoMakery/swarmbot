{ p } = require 'lightsaber'
User = require '../models/user'
Promise = require 'bluebird'

class ApplicationController
  currentUser: ->
    activeUser = @msg.robot.whose @msg
    # User.find activeUser
    new User id: activeUser

  getCommunity: Promise.promisify (fn)->
    if @community?
      fn(null, @community)
      return

    @currentUser().once 'sync', (user)->
      @community = user.get('current_community')
      if @community?
        fn(null, @community)
      else
        fn("No community found")

module.exports = ApplicationController
