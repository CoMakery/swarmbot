class ZorkView
  letters: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  NAV_COLOR: '#43B'
  QUESTION_COLOR: '#0AE'
  INFO_COLOR: '#BBB'
  BODY_COLOR: '#6B6'
  ACTION_COLOR: '#FB6'
  ERROR_COLOR: '#C33'

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

  question: (text) ->
    @coloredMessage @QUESTION_COLOR, text

  info: (text) ->
    @coloredMessage @INFO_COLOR, text

  warning: (text) ->
    @coloredMessage @ERROR_COLOR, text

  coloredMessage: (color, text) ->
    {
      color: color
      text: text
    }

module.exports = ZorkView
