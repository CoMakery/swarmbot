# Commands:
#  hubot space kitty say

# Propz:
#   raysrashmi for https://github.com/raysrashmi/hubot-instagram

{log, p, pjson} = require 'lightsaber'
Instagram = require('instagram-node-lib')

module.exports = (robot) ->

  App.respond /x marks the what$/i, (msg) ->
    msg.send "https://www.youtube.com/watch?v=SFY-Kg1OqAk"

  App.respond /hello$/i, (msg) ->
    msg.send msg.random ["hello my friend", "hey buddy", "maybe it's time to swarm it?", "hi", "hello, it's good to see you, figuratively speaking"]

  App.respond /fork me$/i, (msg) ->
    msg.send "https://github.com/citizencode/swarmbot"

  App.respond /nyan$/i, (msg) ->
    msg.send "https://www.youtube.com/watch?v=QH2-TGUlwu4"

  App.respond /space kitty say$/i, (msg) ->
    authenticateUser(msg)
    count = 1
    Instagram.tags.recent
      name: 'spacekittysay'
      count: count
      complete: (data) ->
        for item in data
          msg.send item['images']['standard_resolution']['url']

authenticateUser = (msg) ->
  config =
    client_key:     process.env.HUBOT_INSTAGRAM_CLIENT_KEY
    client_secret:  process.env.HUBOT_INSTAGRAM_ACCESS_KEY

  unless config.client_key
    msg.send "Please set the HUBOT_INSTAGRAM_CLIENT_KEY environment variable."
    return
  unless config.client_secret
    msg.send "Please set the HUBOT_INSTAGRAM_ACCESS_TOKEN environment variable."
    return
  Instagram.set('client_id', config.client_key)
  Instagram.set('client_secret', config.client_secret)
