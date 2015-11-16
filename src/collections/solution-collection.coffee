{log, p, pjson} = require 'lightsaber'
FirebaseCollection = require './firebase-collection'
Solution = require '../models/solution'

class SolutionCollection extends FirebaseCollection
  model: Solution

module.exports = SolutionCollection
