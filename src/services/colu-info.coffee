{ p } = require 'lightsaber'
{filter} = require 'lodash'
request = require 'request-promise'
swarmbot = require '../models/swarmbot'
Project = require '../models/project.coffee'
User = require '../models/user'


class ColuInfo
  COLU_TIMEOUT: 2*1000

  makeRequest: (uri)->
    request
      uri: uri
      json: true
    .promise()
    .timeout(@COLU_TIMEOUT)

  balances: (user)->
    @allBalances(user)
    .then (result)->
      filter result.balances, (balance)-> balance.name?

  allBalances: (user)->
    new Promise (resolve, reject)=>
      uri = "#{swarmbot.coluExplorerUrl()}/api/getaddressinfo?address=#{user.get('btcAddress')}"
      ColuInfo::makeRequest(uri)
      .then (data)=>
        Promise.map data.assets, (asset)=>
          Project.findBy 'coluAssetId', asset.assetId
          .then (project)=>
            asset.name = project.get('name')
            asset
          .catch (e)=>
            console.error e
            asset
      .then (assets)=>
        resolve {balances: assets}
      .catch Promise.TimeoutError, =>
        @handleColuProblem(reject)
      .catch =>
        @handleColuProblem(reject)

  getAssetInfo: (project)->
    new Promise (resolve, reject)=>
      uri = "#{swarmbot.coluExplorerUrl()}/api/getassetinfowithtransactions?assetId=#{project.get('coluAssetId')}"
      debug uri
      ColuInfo::makeRequest(uri)
      .then (data)=>
        resolve data
      .error (error)=>
        console.error error.stack
        App.notify error
        message = "Sorry, one of our technical partners (Colored Coin provider)
          is currently not available, so functionality may be very limited :("
        reject Promise.OperationalError message

  allHolders: (project)->
    @getAssetInfo(project)
    .then (data)=>
      filter data.holders, (holder)=> holder.address != project.get('coluAssetAddress')

  allHoldersWithNames: (project)->
    @allHolders(project)
    .then (holders)=>
      Promise.map holders, (holder)=>
        User.findBy 'btcAddress', holder.address
        .then (user)=>
          holder.name = user.get('slackUsername')
          holder
        .catch =>
          holder

  handleColuProblem: (reject)->
    reject(new Promise.OperationalError("(Coin information is temporarily unavailable)"))

module.exports = ColuInfo
