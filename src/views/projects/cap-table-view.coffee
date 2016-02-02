{ log, p, pjson } = require 'lightsaber'
{ isEmpty, sum } = require 'lodash'
ZorkView = require '../zork-view'

class CapTableView extends ZorkView
  constructor: (@project, @capTable)->
    @menu = {}

  render: ->
    amounts = []
    names = []
    for {name, address, amount} in @capTable
      amounts.push amount
      names.push name or '(unknown)'

    if isEmpty names
      @warning "No awards have yet been issued for this project."
    else
      total = sum amounts
      amounts = (amount * 100 / total for amount in amounts)
      for _, i in @capTable
        roundedAmount = Math.round amounts[i]
        names[i] = encodeURIComponent "#{names[i]} #{roundedAmount}%"

      chartUrl = "https://chart.googleapis.com/chart?chs=450x200&chd=t:#{amounts.join(',')}&chma=30,30,30,30&cht=p3&chl=#{names.join('|')}"
      debug chartUrl
      [
        {
          title: @project.get 'name'
          image_url: chartUrl
        }
      ]

module.exports = CapTableView
