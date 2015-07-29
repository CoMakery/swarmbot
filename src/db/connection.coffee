neo4j = require 'neo4j'

connection = new neo4j.GraphDatabase
  url: process.env['NEO4J_URL'] || process.env['GRAPHENEDB_URL'] || 'http://neo4j:neo4j@localhost:7474'
  auth: process.env['NEO4J_AUTH']

module.exports = connection
