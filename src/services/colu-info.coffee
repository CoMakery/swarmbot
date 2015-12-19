debug = require('debug')('app')
{filter} = require 'lodash'
request = require 'request-promise'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
Project = require '../models/project.coffee'
User = require '../models/user'


class ColuInfo
  balances: (user)->
    @allBalances(user).then (balances)->
      filter balances, (balance)-> balance.name?

  allBalances: (user)->
    new Promise (resolve, reject)=>
      uri = "#{swarmbot.coluExplorerUrl()}/api/getaddressinfo?address=#{user.get('btcAddress')}"
      debug uri
      request
        uri: uri
        json: true
      .then (data)=>
        Promise.map data.assets, (asset)->
          Project.findBy 'coluAssetId', asset.assetId
          .then (project)=>
            asset.name = project.get('name')
            asset
          .catch =>
            asset
        .then (assets)=>
          resolve assets
          # each asset has a .balance, .name, .assetId
      .error (error)=>
        debug error.message
        reject Promise.OperationalError("(Currently not available)")


  getAssetInfo: (project)->
    new Promise (resolve, reject)=>
      uri = "#{swarmbot.coluExplorerUrl()}/api/getassetinfowithtransactions?assetId=#{project.get('coluAssetId')}"
      debug uri
      request
        uri: uri
        json: true
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
