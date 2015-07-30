Identity = require './identity'

class Claim

  @create: (data) ->
    { source, target, value, content } = data
    Identity.put name: source, console.log
    Identity.put name: target, console.log

    # add edge source -> { value, content } -> target

module.exports = Claim
