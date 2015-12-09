debug = require('debug')('app')
{filter} = require 'lodash'
request = require 'request-promise'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
DCO = require '../models/dco.coffee'
User = require '../models/user'


class ColuInfo
  balances: (user)->
    @allBalances(user).then (balances)->
      filter balances, (balance)-> balance.name?

  allBalances: (user)->
    new Promise (resolve, reject)=>
      uri = "#{swarmbot.coluExplorerUrl()}/api/getaddressinfo?address=#{user.get('btc_address')}"
      debug uri
      request
        uri: uri
        json: true
      .then (data)=>
        Promise.map data.assets, (asset)->
          DCO.findBy 'coluAssetId', asset.assetId
          .then (dco)=>
            asset.name = dco.get('name')
            asset
          .catch =>
            asset
        .then (assets)=>
          resolve assets
          # each asset has a .balance, .name, .assetId
      .error (error)=>
        debug error.message
        reject Promise.OperationalError("(Currently not available)")


  getAssetInfo: (dco)->
    new Promise (resolve, reject)=>
      uri = "#{swarmbot.coluExplorerUrl()}/api/getassetinfowithtransactions?assetId=#{dco.get('coluAssetId')}"
      debug uri
      request
        uri: uri
        json: true
      .then (data)=>
        resolve data
      .error (error)=>
        debug error.message
        reject Promise.OperationalError("(Currently not available)")

  allHolders: (dco)->
    @getAssetInfo(dco)
    .then (data)=>
      filter data.holders, (holder)=> holder.address != dco.get('coluAssetAddress')

  allHoldersWithNames: (dco)->
    @allHolders(dco)
    .then (holders)=>
      Promise.map holders, (holder)=>
        User.findBy 'btc_address', holder.address
        .then (user)=>
          holder.name = user.get('slack_username')
          holder
        .catch =>
          holder


module.exports = ColuInfo
