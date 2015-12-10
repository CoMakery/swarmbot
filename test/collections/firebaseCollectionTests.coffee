{log, p, pjson} = require 'lightsaber'
FirebaseCollection = require '../../src/collections/firebase-collection'
require '../helpers/testHelper'

class Model
  constructor: (@id)->

class SomeCollection extends FirebaseCollection
  model: Model

describe 'SomeCollection', ->

  describe 'find', ->
    it "finds the correct model instance in the collection", ->
      a = new Model 'a'
      b = new Model 'b'
      collection = new SomeCollection [a, b]
      found_b = collection.find (model)-> model.id is 'b'
      found_b.should.eq b
      collection.models.should.deep.eq [a, b]

  describe 'filter', ->
    it "finds the correct model instances in the collection", ->
      a = new Model 1
      b = new Model 2
      c = new Model 3
      collection = new SomeCollection [a, b, c]
      lowNumbers = collection.filter (model)-> model.id <= 2
      lowNumbers.should.deep.eq [a, b]
      collection.models.should.deep.eq [a, b, c]
