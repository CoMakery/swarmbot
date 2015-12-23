debug = require('debug')('app')
{ p } = require 'lightsaber'
{filter} = require 'lodash'
request = require 'request-promise'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
Project = require '../models/project.coffee'
User = require '../models/user'


class ColuInfo
  makeRequest: (uri)->
    request
      uri: uri
      json: true
    .promise()
    .timeout(500)

  balances: (user)->
    @allBalances(user).then (result)->
      filter result.balances, (balance)-> balance.name?

  allBalances: (user)->
    new Promise (resolve, reject)=>
      uri = "#{swarmbot.coluExplorerUrl()}/api/getaddressinfo?address=#{user.get('btcAddress')}"
      debug uri
      ColuInfo::makeRequest(uri)
      .catch(Promise.TimeoutError, (error)->
        throw Promise.OperationalError("Balance information is temporarily unavailable"))
      .then (data)=>
        Promise.map data.assets, (asset)=>
          Project.findBy 'coluAssetId', asset.assetId
          .then (project)=>
            asset.name = project.get('name')
            asset
          .catch (e)=>
            asset
      .then (assets)=>
        resolve {balances: assets}
        # each asset has a .balance, .name, .assetId
      .error (error)=>
        debug error.message
        resolve Promise.OperationalError("(Currently not available)")

  getAssetInfo: (project)->
    new Promise (resolve, reject)=>
      uri = "#{swarmbot.coluExplorerUrl()}/api/getassetinfowithtransactions?assetId=#{project.get('coluAssetId')}"
      debug uri
      ColuInfo::makeRequest(uri)
      .then (data)=>
        resolve data
      .error (error)=>
        debug error.message
        reject Promise.OperationalError("(Currently not available)")

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


module.exports = ColuInfo
