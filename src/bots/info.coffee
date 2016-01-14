# Commands:
#

{log, p, pjson} = require 'lightsaber'
swarmbot = require '../models/swarmbot'

module.exports = (robot)->

  App.addResponder /airbrake exception! WxmhxTuxKfjnVQ3mLgGZaG2KPn$/i, (msg)->
    throw new Error('I am a test exception')

  App.addResponder /airbrake notify! WxmhxTuxKfjnVQ3mLgGZaG2KPn$/i, (msg)->
    App.notify 'Hi through Airbrake'

  App.addResponder /colu WxmhxTuxKfjnVQ3mLgGZaG2KPn/i, (msg)->
    swarmbot.colu()

  App.addResponder /welcome me WxmhxTuxKfjnVQ3mLgGZaG2KPn$/i, (msg)-> App.greet msg

  App.addResponder /what data\? WxmhxTuxKfjnVQ3mLgGZaG2KPn$/i, (msg)->
    p pjson msg
    msg.send 'check the logs'
