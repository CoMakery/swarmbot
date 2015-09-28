Promise = require 'bluebird'
FirebaseModel = require './firebase-model'

class Member extends FirebaseModel
  hasParent: true
  urlRoot: "members"
  @find: (id, { parent }) ->
    new Member({id: id}, parent: parent)

module.exports = Member
