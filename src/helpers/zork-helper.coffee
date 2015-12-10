class ZorkHelper
  ACTION_COLOR: '#FBD48A'
  BODY_COLOR: '#3498DB'
  INFO_COLOR: '#56E6CE'
  NAV_COLOR: '#3498DB'
  QUESTION_COLOR: '#56E6CE'
  WARNING_COLOR: '#FC5E70'

  action:   (text)-> @message @ACTION_COLOR, text
  body:     (text)-> @message @BODY_COLOR, text
  info:     (text)-> @message @INFO_COLOR, text
  question: (text)-> @message @QUESTION_COLOR, text
  warning:  (text)-> @message @WARNING_COLOR, text

  message: (color, text)->
    {
      text: text
    }

module.exports = ZorkHelper
