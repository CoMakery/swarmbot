# Description:
#   Informational and help related commands
#
# Commands:
#   hubot what what
#   hubot x marks the what

# Not implemented yet:
#   hubot tag <community name> <tag>
#   hubot info <community name>

{log, p, pjson} = require 'lightsaber'

module.exports = (robot) ->

  robot.respond /what what$/i, (msg) ->
    msg.send ":swarm:"

  robot.respond /x marks the what$/i, (msg) ->
    msg.send "https://www.youtube.com/watch?v=SFY-Kg1OqAk"

  robot.respond /tag (.+) = (.+)$/i, (msg) ->
    msg.match.shift()
    [dcoKey, tag] = msg.match
    # write tag to trust exchange

  robot.respond /info (.+) $/i, (msg) ->
    msg.match.shift()
    [dcoKey] = msg.match
    # pulls tag and other relevant info from trust exchange / dbrain
