{ p } = require 'lightsaber'
sinon = require 'sinon'
nock = require 'nock'
Promise = require 'bluebird'
{ createUser, createProject } = require '../helpers/test-helper'
ColuInfo = require '../../src/services/colu-info'


describe 'ColuInfo', ->
  beforeEach ->
    @coluInfo = new ColuInfo()
    ColuInfo.prototype.getAssetInfo.restore?()
    ColuInfo.prototype.balances.restore?()

  afterEach ->
    ColuInfo.prototype.makeRequest.restore?()

  describe '#balances', ->
    it 'calls out to colu and retrieves info for a bitcoin wallet, then filters to ones in our DB', ->
      createUser()
      .then (@user)=>
        createProject
          name: 'project1'
          coluAssetId: 'project1AssetId'
      .then (@project1)=>
        createProject
          name: 'project2'
          coluAssetId: 'project2AssetId'
      .then (@project2)=>
        ColuInfo.prototype.makeRequest.restore?()
        sinon.stub(ColuInfo.prototype, 'makeRequest').returns Promise.resolve
          assets: [
            {
              assetId: 'project1AssetId'
              address:'mkvqtc25vKXp7Xf5SqqHVZYU5BAgwTas8B'
              amount: 2
            }
            {
              assetId: 'project2AssetId'
              address:'foobarbaz'
              amount: 3
            }
          ]
        @coluInfo.balances(@user)
      .then (result)=>
        result.should.deep.eq [
          {
            address: 'mkvqtc25vKXp7Xf5SqqHVZYU5BAgwTas8B'
            amount: 2
            assetId: 'project1AssetId'
            name: 'project1'
          }
          {
            address: 'foobarbaz'
            amount: 3
            assetId: 'project2AssetId'
            name: 'project2'
          }
        ]

    xdescribe 'timeout test fails regularly on CI : (', ->
      it 'returns an error message in the result if the app times out', ->
        sinon.stub(ColuInfo.prototype, 'makeRequest').returns(Promise.reject(new Promise.TimeoutError("Zomg timed out")))
        createUser()
        .then (@user)=>
          @coluInfo.balances(@user)
        .then ->
          assert.fail()
        .error (e)=>
          e.message.should.eq '(Coin information is temporarily unavailable)'

  describe "#allBalances", ->
    beforeEach ->
      nock 'https://explorer.coloredcoins.org'
        .get '/api/getaddressinfo?address=3HNSiAq7wFDaPsYDcUxNSRMD78qVcYKicw'
        .replyWithError('Colu is down')

    it 'returns an error message if Colu is down', ->
      createUser()
      .then (@user)=>
        @coluInfo.allBalances(@user)
      .then ->
        assert.fail()
      .error (e)=>
        e.message.should.eq '(Coin information is temporarily unavailable)'
