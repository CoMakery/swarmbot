{ log, p, pjson } = require 'lightsaber'
{ isEmpty, sum } = require 'lodash'
ZorkView = require '../zork-view'

class BalanceView extends ZorkView
  constructor: ({@assets}) ->
    @menu = {}

  render: ->
    if isEmpty @assets
      @warning "No rewards have been sent to this address. Try submitting a solution!"
    else
      @body ( "#{asset.balance} units of #{asset.name or asset.assetId}" for asset in @assets ).join("\n")

module.exports = BalanceView
