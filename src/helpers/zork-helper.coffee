class ZorkHelper
  NAV_COLOR: '#43B'
  QUESTION_COLOR: '#0AE'
  INFO_COLOR: '#444'  # BBB
  BODY_COLOR: '#6B6'
  ACTION_COLOR: '#FB6'
  ERROR_COLOR: '#C33'

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

module.exports = ZorkHelper
