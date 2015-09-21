{ p } = require 'lightsaber'
User = require '../models/user'
Promise = require 'bluebird'

class ApplicationController
  currentUser: ->
    activeUser = @msg.robot.whose @msg
    # User.find activeUser
    new User id: activeUser

  getCommunity: ->
    new Promise (resolve, reject)=>
      if @community?
        resolve(@community)
        return

      @currentUser().once 'sync', (user)->
        @community = user.get('current_community')
        if @community?
          resolve(@community)
        else
          reject()

module.exports = ApplicationController
