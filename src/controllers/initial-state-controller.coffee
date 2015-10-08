{ log, p, pjson } = require 'lightsaber'

class InitialStateController
  constructor: (@msg, @user) ->

  process: ->
    p "Processing", @msg.message, @msg

module.exports = InitialStateController
