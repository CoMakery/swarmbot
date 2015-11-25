class ZorkHelper
  ACTION_COLOR: '#FBD48A'
  BODY_COLOR: '#3498DB'
  INFO_COLOR: '#56E6CE'
  NAV_COLOR: '#34A9DB'
  QUESTION_COLOR: '#56E6CE'
  WARNING_COLOR: '#FC5E70'

  action:   (text) -> @coloredMessage @ACTION_COLOR, text
  body:     (text) -> @coloredMessage @BODY_COLOR, text
  info:     (text) -> @coloredMessage @INFO_COLOR, text
  question: (text) -> @coloredMessage @QUESTION_COLOR, text
  warning:  (text) -> @coloredMessage @WARNING_COLOR, text

  coloredMessage: (color, text) ->
    {
      color: color
      text: text
    }

module.exports = ZorkHelper
