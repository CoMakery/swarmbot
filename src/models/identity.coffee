db = require '../db/connection'

class Identity

  #
  # Create identity  -- TODO create or update
  #
  @put: (props) ->
    query = """
      CREATE (i:Identity {props})
      RETURN i
    """
    db.cypher { query: query, params: {props} }, (err, results) ->
      if isConstraintViolation(err)
        console.error 'The identity ‘' + props.name + '’ is taken.'
      else if err
        throw err

  @get: (name) ->
    new Identity

  reputation: ->
    "stub reputation"

module.exports = Identity
