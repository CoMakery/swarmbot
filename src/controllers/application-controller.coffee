{ log, p, pjson } = require 'lightsaber'
User = require '../models/user'
Promise = require 'bluebird'
DCO = require '../models/dco'

class ApplicationController
  currentUser: ->
    activeUserId = @msg.robot.whose @msg
    # User.find activeUser
    new User id: activeUserId

  getCommunity: Promise.promisify (fn)->
    if @community?
      dco = DCO.find(@community)
      fn(null, dco)
      return

    @currentUser().fetch().then (user) ->
      @community = user.get('current_dco')
      if @community?
        dco = DCO.find(@community)
        fn(null, dco)
      else
        fn("No community found")

    .catch (error) =>
      log error
      @msg.send "Sorry, unable to complete this command."

    # user.once 'error', (user)->
    #   p "Error synchronizing User state", arguments
    #   throw new Error("Error synchronizing user state", arguments)


module.exports = ApplicationController
