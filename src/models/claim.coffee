class Claim

  @create: (data) ->
    { source, target, value, content } = data
    Identity.put name: source
    Identity.put name: target

    # add edge source -> { value, content } -> target

module.exports = Claim
