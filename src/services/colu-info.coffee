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

  balances: (user)->
    @allBalances(user).then (result)->
      balances = filter result.balances, (balance)-> balance.name?
      {balances: balances, error: result.error}

  allBalances: (user)->
    new Promise (resolve, reject)=>
      uri = "#{swarmbot.coluExplorerUrl()}/api/getaddressinfo?address=#{user.get('btcAddress')}"
      debug uri
      ColuInfo::makeRequest(uri)
      .timeout(500)
      .error(Promise.TimeoutError, (error)->
        return resolve({balances: [], error: "Balance information is temporarily unavailable"}))
      .then (data)=>
        Promise.map data.assets, (asset)->
          Project.findBy 'coluAssetId', asset.assetId
          .then (project)=>
            asset.name = project.get('name')
            asset
          .catch =>
            asset
        .then (assets)=>
          resolve {balances: assets}
          # each asset has a .balance, .name, .assetId
      .error (error)=>
        debug error.message
        reject Promise.OperationalError("(Currently not available)")


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
