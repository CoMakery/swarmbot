# Description:
#   Initialize the bot.
#   Note: this file name starts with a special character in order to load first;
#   Hubot loads scripts in sorted order.
#
# Commands:
#

global.App = require '../app'  # global to avoid cyclic dependencies

InitBot = (robot)-> App.init robot

module.exports = InitBot
