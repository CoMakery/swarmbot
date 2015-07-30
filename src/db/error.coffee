neo4j = require 'neo4j'

isConstraintViolation = (err) ->
  err instanceof neo4j.ClientError &&
    err.neo4j.code is 'Neo.ClientError.Schema.ConstraintViolation'

module.exports = {isConstraintViolation}
