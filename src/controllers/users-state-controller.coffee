
{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './state-application-controller'
DcoCollection = require '../collections/dco-collection'
ShowView = require '../views/users/show-view'

class UsersStateController extends ApplicationController

  # map of state name -> controller action
  stateActions:
    myAccount: 'myAccount'

  myAccount: ->
    # show current user data
    @render(new ShowView @currentUser)



module.exports = UsersStateController
