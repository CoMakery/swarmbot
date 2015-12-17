{ json, log, p, pjson, type } = require 'lightsaber'

class ZorkHelper

  # NOTE: WE USED TO USE COLORS, BUT NO LONGER DO.
  # KEEP THEM AROUND UNTIL MARCH 2016;
  # IF THEY ARE NOT IN USE BY THEN, DELETE.

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
    if type(text) is 'string'
      {
        # color
        text
      }
    else
      throw new Error "expected string, got: #{pjson text}"

module.exports = ZorkHelper
