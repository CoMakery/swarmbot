# Commands:
#

{log, p, pjson} = require 'lightsaber'
Instagram = require('instagram-node-lib')
swarmbot = require '../models/swarmbot'

module.exports = (robot)->

  App.respond /airbrake exception! WxmhxTuxKfjnVQ3mLgGZaG2KPn$/i, (msg)->
    throw new Error('I am a test exception')

  App.respond /airbrake notify! WxmhxTuxKfjnVQ3mLgGZaG2KPn$/i, (msg)->
    if App.airbrake
      err = new Error('Hi through Airbrake')
      App.airbrake.notify err, (err, url)->
        if (err)
          throw err
        else
          msg.send "Delivered to #{url}"
    else
      msg.send "No airbrake configured"

  App.respond /colu WxmhxTuxKfjnVQ3mLgGZaG2KPn/i, (msg)->
    swarmbot.colu()

  App.respond /stats WxmhxTuxKfjnVQ3mLgGZaG2KPn/i, (msg)->

    usersRef = swarmbot.firebase().child('users')

    usersRef.orderByChild("account_created").startAt(Date.now() - (1000*60*60*24*7)).once 'value', (snapshot)=>
      msg.send "#{snapshot.numChildren()} new users signed up in the last week."

    usersRef.orderByChild("lastActiveOnSlack").startAt(Date.now() - (1000*60*60*24*7)).once 'value', (snapshot)=>
      msg.send "There are #{snapshot.numChildren()} users active in the last week."

    usersRef.orderByChild("lastActiveOnSlack").startAt(Date.now() - (1000*60*60*24*30)).once 'value', (snapshot)=>
      msg.send "There are #{snapshot.numChildren()} users active in the last month."

    usersRef.once 'value', (snapshot)=>
      msg.send "There are #{snapshot.numChildren()} users total."
