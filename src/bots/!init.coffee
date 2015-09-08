# Commands:
# 

Firebase = require 'firebase'
Colu = require('colu')

InitBot = (robot) ->

  throw new Error if robot.swarmbot?
  robot.swarmbot = {}

  robot.swarmbot.firebase = new Firebase 'https://dazzle-staging.firebaseio-demo.com/'  # Swarm prduction.  Really.
  robot.swarmbot.whose = (message) -> "@#{message.message.user.name}"

  # Colu:
  privateSeed = 'abcd4986fdac1b3a710892ef6eaa708d619d67100d0514ab996582966f927982'
  settings =
    network: 'testnet'
    privateSeed: privateSeed
  robot.swarmbot.colu = new Colu settings


module.exports = InitBot
