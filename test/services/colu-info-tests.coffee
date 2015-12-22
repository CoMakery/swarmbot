{ p } = require 'lightsaber'
sinon = require 'sinon'
Promise = require 'bluebird'
{ createUser } = require '../helpers/test-helper'
ColuInfo = require '../../src/services/colu-info'


describe 'ColuInfo', ->
  beforeEach ->
    @coluInfo = new ColuInfo()
    ColuInfo.prototype.getAssetInfo.restore
    ColuInfo.prototype.balances.restore

  describe '#balances', ->
#    it 'calls out to colu and retrieves info for a bitcoin wallet, then filters to ones in our DB', ->
#      sinon.stub(ColuInfo.prototype, 'makeRequest').returns Promise.resolve({})
#      createUser()
#      .then (@user)=>
#        p @coluInfo.balances(@user)

    it 'returns an error message in the result if the app times out', ->
#      sinon.stub(ColuInfo.prototype, 'makeRequest').returns Promise.reject(new Promise.TimeoutError("Zomg timed out"))
      sinon.stub(ColuInfo.prototype, 'makeRequest').returns(Promise.reject(new Promise.TimeoutError("Zomg timed out")))
      createUser()
      .then (@user)=>
        @coluInfo.balances(@user)
        .then (result)->
          result.error.should.eq 'Balance information is temporarily unavailable'