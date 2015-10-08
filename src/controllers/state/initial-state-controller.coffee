{ log, p, pjson } = require 'lightsaber'

class InitialStateController
  constructor: (@msg) ->

  process: ->
    p "Processing", @msg.message, @msg

module.exports = InitialStateController
