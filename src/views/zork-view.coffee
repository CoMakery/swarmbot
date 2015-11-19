class ZorkView
  letters: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  NAV_COLOR: '#549'
  QUESTION_COLOR: '#0AE'
  INFO_COLOR: '#BBB'
  BODY_COLOR: '#6B6'
  ACTION_COLOR: '#FB6'

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
    {
      color: @QUESTION_COLOR
      text: text
    }

module.exports = ZorkView
