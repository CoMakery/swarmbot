class ZorkHelper
  ACTION_COLOR: '#FB6'
  BODY_COLOR: '#6B6'
  INFO_COLOR: '#BBB'
  NAV_COLOR: '#43B'
  QUESTION_COLOR: '#0AE'
  WARNING_COLOR: '#C33'

  action: (text) -> @coloredMessage @ACTION_COLOR, text
  body: (text) -> @coloredMessage @BODY_COLOR, text
  info: (text) -> @coloredMessage @INFO_COLOR, text
  question: (text) -> @coloredMessage @QUESTION_COLOR, text
  warning: (text) -> @coloredMessage @WARNING_COLOR, text

  coloredMessage: (color, text) ->
    {
      color: color
      text: text
    }

module.exports = ZorkHelper
