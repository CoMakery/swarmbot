{log, p, pjson} = require 'lightsaber'
FirebaseCollection = require './firebase-collection'
Proposal = require '../models/proposal'

class ProposalCollection extends FirebaseCollection
  model: Proposal

module.exports = ProposalCollection
