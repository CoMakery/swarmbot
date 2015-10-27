class ZorkView
  renderMenu: ->
    if @orderedMenu?
      lines = for [key, menuItem] in @orderedMenu
        item = menuItem.text
        item = "#{key}: #{item}" if key?
        item
      lines.join("\n")
    else
      lines = for key, menuItem of @menu
        "#{key}: #{menuItem.text}"
      lines.join("\n")

  bold: (text) -> "*#{text}*"

module.exports = ZorkView
