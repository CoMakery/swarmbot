{ log, p, pjson } = require 'lightsaber'
{ isEmpty, sum } = require 'lodash'
ZorkView = require '../zork-view'

class CapTableView extends ZorkView
  constructor: ({@capTable}) ->
    @menu = {}

  render: ->
    amounts = []
    names = []
    for {name, address, amount} in @capTable
      if amount < 99000000
        amounts.push amount
        names.push name or address

    if isEmpty names
      "No cap table to show.  Try rewarding some solutions first."
    else
      total = sum amounts
      amounts = (amount * 100 / total for amount in amounts)
      """
      https://chart.googleapis.com/chart?chs=450x200&chd=t:#{amounts.join(',')}&cht=p3&chl=#{names.join('|')}
      """

module.exports = CapTableView
