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
        .get '/api/getaddressinfo?address=some bitcoin address'
        .replyWithError('Colu is down')

    it 'returns an error message if Colu is down', ->
      createUser()
      .then (@user)=>
        @coluInfo.allBalances(@user)
      .then ->
        assert.fail()
      .error (e)=>
        e.message.should.eq '(Coin information is temporarily unavailable)'

  describe "#getAssetInfo", ->
    beforeEach (done)->
      createProject()
      .then (@project)=>
        done()

    describe 'when there are no errors', ->
      beforeEach ->
        ColuInfo.prototype.getAssetInfo.restore?()
        sinon.stub(ColuInfo::, 'makeRequest').returns(Promise.resolve("this is a response"))

      it 'calls out to colu with the correct url and returns a response', ->
        (new ColuInfo).getAssetInfo(@project)
        .then (data)->
          data.should.eq "this is a response"

    describe 'when there are errors', ->
      beforeEach ->
        sinon.stub(App, 'notify')
        ColuInfo.prototype.getAssetInfo.restore?()
        sinon.stub(ColuInfo::, 'makeRequest').returns(new Promise (resolve, reject)-> reject(new Promise.OperationalError('bang')))

      afterEach ->
        App.notify.restore?()

      it 'calls App.notify and returns an Operational error', ->
        (new ColuInfo).getAssetInfo(@project)
        .then (data)->
          assert.fail()
        .catch (e)->
          App.notify.getCall(0).args[0].message.should.eq "bang"
          e.message.should.eq "Sorry, one of our technical partners (Colored Coin provider) is currently not available, so functionality may be very limited :("
