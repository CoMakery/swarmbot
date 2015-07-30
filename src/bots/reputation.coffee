# Description:
#   Reputation commands 
#
# Commands:
#   hubot rate <person> <value>% on <description>
#   hubot show reputation of <person>
#

Claim           = require '../models/claim'
Identity        = require '../models/identity'

ReputationBotCommands = (robot) ->

  ##
  ##   hubot show reputation of <person>
  ##
  robot.respond /show reputation of (.+)/i, (msg) ->
    name = msg.match[1]
    identity = Identity.get name
    msg.send identity.reputation()

  robot.respond /rate (.+) ([\d.]+)% on (.+)/i, (msg) ->
    msg.match.shift()
    [target, value, content] = msg.match
    source = 'TODO get the slack username?'
    Claim.create { source, target, value, content }
    msg.send "Rated."

module.exports = ReputationBotCommands
