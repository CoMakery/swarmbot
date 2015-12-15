{log, p, pjson, json} = require 'lightsaber'
{extend} = require 'lodash'
ZorkHelper = require '../helpers/zork-helper'

class ZorkView

  letters: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

  renderMenu: ->
    @renderMenuItems @menu

  renderOrderedMenuItems: (items)->
    lines = for [key, menuItem] in items
      item = menuItem.text
      item = "#{key}: #{item}" if key?
      item
    lines.join("\n")

  renderMenuItems: (items)->
    lines = for key, menuItem of items
      "#{key}: #{menuItem.text}"
    lines.join("\n")

  bold: (text)-> "*#{text}*"

  bitcoinAddress: -> @currentUser.get('btc_address') or "None"

extend ZorkView::, ZorkHelper::

module.exports = ZorkView
