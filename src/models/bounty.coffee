class Bounty

  constructor: ({@bountyRef}) ->

  get: (property, cb) ->
    @bountyRef.child(property).on 'value', (snapshot) -> cb snapshot.val()

module.exports = Bounty
