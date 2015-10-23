class ZorkView
  renderMenu: ->
    lines = for i, menuItem of @menu
      "#{i}: #{menuItem.text}"
    lines.join("\n")

  bold: (text) -> "*#{text}*"

module.exports = ZorkView
