{ log, p, pjson } = require 'lightsaber'
{ isEmpty, sum } = require 'lodash'
ZorkView = require '../zork-view'

class CapTableView extends ZorkView
  constructor: ({@project, @capTable})->
    @menu = {}

  render: ->
    amounts = []
    names = []
    for {name, address, amount} in @capTable
      amounts.push amount
      names.push name or address

    if isEmpty names
      @warning "No awards have yet been issued for this project."
    else
      total = sum amounts
      amounts = (amount * 100 / total for amount in amounts)
      chartUrl = "https://chart.googleapis.com/chart?chs=450x200&chd=t:#{amounts.join(',')}&cht=p3&chl=#{names.join('|')}"
      [
        title: @project.get 'name'
        image_url: chartUrl
        fallback: chartUrl
      ]

module.exports = CapTableView
