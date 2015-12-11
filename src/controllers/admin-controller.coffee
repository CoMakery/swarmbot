{log, p, pjson} = require 'lightsaber'
ApplicationController = require './application-controller'
Promise = require 'bluebird'
DCO = require '../models/dco'
swarmbot = require '../models/swarmbot'
Award = require '../models/award'
User = require '../models/user'
AwardCollection = require '../collections/award-collection'
{ values, assign, map } = require 'lodash'

class AdminController extends ApplicationController

  stats: (@msg)->

    usersRef = swarmbot.firebase().child('users')

    usersRef.orderByChild("account_created").startAt(Date.now() - (1000*60*60*24*7)).once 'value', (snapshot)=>
      @msg.send "#{snapshot.numChildren()} new users signed up in the last week."

    usersRef.orderByChild("last_active_on_slack").startAt(Date.now() - (1000*60*60*24*7)).once 'value', (snapshot)=>
      @msg.send "There are #{snapshot.numChildren()} users active in the last week."

    usersRef.orderByChild("last_active_on_slack").startAt(Date.now() - (1000*60*60*24*30)).once 'value', (snapshot)=>
      @msg.send "There are #{snapshot.numChildren()} users active in the last month."

    usersRef.once 'value', (snapshot)=>
      @msg.send "There are #{snapshot.numChildren()} users total."

module.exports = AdminController
