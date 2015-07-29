class Claim

  @create: (data) ->
    { source, target, value, content } = data
    # add node source unless exists
    # add node target unless exists
    # add edge source -> { value, content } -> target

module.exports = Claim
