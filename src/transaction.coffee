Router = require './router'

class Transaction
  constructor: -> @router = new Router
  input: (@msg) ->
  route: -> @router.route @msg, @
  respond: (@response) -> @msg.send @response

module.exports = Transaction
