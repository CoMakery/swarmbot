# Commands:
#

{log, p, pjson} = require 'lightsaber'
swarmbot = require '../models/swarmbot'

module.exports = (robot)->

  App.addResponder /airbrake exception! WxmhxTuxKfjnVQ3mLgGZaG2KPn$/i, (msg)->
    throw new Error('I am a test exception')

  App.addResponder /airbrake notify! WxmhxTuxKfjnVQ3mLgGZaG2KPn$/i, (msg)->
    if App.airbrake
      err = new Error('Hi through Airbrake')
      App.airbrake.notify err, (err, url)->
        if (err)
          throw err
        else
          msg.send "Delivered to #{url}"
    else
      msg.send "No airbrake configured"

  App.addResponder /colu WxmhxTuxKfjnVQ3mLgGZaG2KPn/i, (msg)->
    swarmbot.colu()
