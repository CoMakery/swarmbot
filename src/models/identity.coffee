db = require '../db/connection'
error = require '../db/error'

{ isConstraintViolation } = error

class Identity

  #
  # Create identity  -- TODO create or update
  #
  @put: (props, callback) ->
    query = """
      CREATE (identity:Identity {props})
      RETURN identity
    """
    db.cypher { query: query, params: {props} }, (err, results) ->
      if isConstraintViolation(err)
        console.error 'The identity ‘' + props.name + '’ is taken.'
      else if err
        throw err
      identity = new Identity results[0]['identity']
      callback identity

  @get: (name) ->
    new Identity

  reputation: ->
    "stub reputation"

module.exports = Identity
