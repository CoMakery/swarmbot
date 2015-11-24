{ log, p, pjson } = require 'lightsaber'
{ filter } = require 'lodash'
ZorkView = require '../zork-view'

class AdvancedCommandsView extends ZorkView
  BONUS_COMMAND_EXPRESSION: /\b(cat|dawg|kitty)\b/i

  constructor: (@robot) ->
    @menu = {}
    @menu[0] = { text: "back", transition: 'exit' }

  render: ->
    fallback = """
    #{@bold 'Advanced Commands'}

    #{@availableCommands()}
    """
    [
      color: @ACTION_COLOR
      title: 'Advanced Commands'
      text: @availableCommands()
    ]

  availableCommands: ->
    cmds = @robot.helpCommands()
    prefix = @robot.alias or @robot.name
    cmds = for cmd in cmds
      cmd = cmd.replace /hubot/ig, @robot.name
      cmd.replace new RegExp("^#{@robot.name}"), prefix

    cmds = filter cmds, (cmd) => not cmd.match @BONUS_COMMAND_EXPRESSION
    cmds.join "\n"

module.exports = AdvancedCommandsView
