{ log, p, pjson } = require 'lightsaber'
Router = require './router'

class Transaction
  constructor: -> @router = new Router

  respondTo: (@msg) ->
    pr = @router.route @msg
    pr.then (response) =>
      p 555, response
      @msg.send response

  # input: (@msg) ->

  # route: -> @router.route @msg, @

  # respond: (@response) -> @msg.send @response

module.exports = Transaction
