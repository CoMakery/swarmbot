# Description:
#   Informational and help related commands
#
# Commands:
#   hubot x marks the what
#   hubot hello

# Not in use:
#   hubot tag <community name> <tag>
#   hubot info <community name>

{log, p, pjson} = require 'lightsaber'

module.exports = (robot) ->

  robot.respond /x marks the what$/i, (msg) ->
    msg.send "https://www.youtube.com/watch?v=SFY-Kg1OqAk"

  robot.respond /hello$/i, (msg) ->
    msg.send msg.random ["hello my friend", "hey buddy", "maybe it's time to swarm it?", "hi", "hello, it's good to see you, figuratively speaking"]

  robot.respond /tag (.+) = (.+)$/i, (msg) ->
    msg.match.shift()
    [dcoKey, tag] = msg.match
    # write tag to trust exchange

  robot.respond /info (.+) $/i, (msg) ->
    msg.match.shift()
    [dcoKey] = msg.match
    # pulls tag and other relevant info from trust exchange / dbrain
