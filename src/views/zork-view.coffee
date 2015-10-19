class ZorkView
  renderMenu: ->
    lines = for i, menuItem of @menu
      "#{i}: #{menuItem.text}"
    lines.join("\n")

module.exports = ZorkView
