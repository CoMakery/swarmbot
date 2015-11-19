class ZorkView
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

  bold: (text) -> "*#{text}*"

module.exports = ZorkView
