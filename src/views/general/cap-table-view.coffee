{ log, p, pjson } = require 'lightsaber'
{ sum } = require 'lodash'
ZorkView = require '../zork-view'

class CapTableView extends ZorkView
  constructor: ({@capTable}) ->
    @menu = {}

  render: ->
    amounts = []
    names = []
    for {address, amount} in @capTable
      amounts.push amount
      names.push address

    total = sum amounts
    amounts = (amount * 100 / total for amount in amounts)
    """
    https://chart.googleapis.com/chart?chs=450x200&chd=t:#{amounts.join(',')}&cht=p3&chl=#{names.join('|')}
    """

module.exports = CapTableView
