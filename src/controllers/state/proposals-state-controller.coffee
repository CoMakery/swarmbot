{ log, p, pjson } = require 'lightsaber'

class ProposalsStateController
  constructor: (@msg) ->

  process: ->
    p "Processing proposals state", @msg.message

    switch @msg.message.text
      when '1' then p 1
      when '2' then p 2



module.exports = ProposalsStateController
