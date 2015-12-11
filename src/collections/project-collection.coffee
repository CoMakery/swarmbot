{log, p, pjson} = require 'lightsaber'
FirebaseCollection = require './firebase-collection'
Project = require '../models/project'

class ProjectCollection extends FirebaseCollection
  model: Project

module.exports = ProjectCollection
