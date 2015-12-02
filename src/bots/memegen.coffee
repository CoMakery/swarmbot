# Description:
#   Generates memes via the Imgflip Meme Generator API
#
# Configuration:
#   IMGFLIP_API_USERNAME [optional, overrides default imgflip_hubot account]
#   IMGFLIP_API_PASSWORD [optional, overrides default imgflip_hubot account]
#
# Commands:
#   hubot grumpy cat <text> - Grumpy Cat with text on the bottom
#   hubot Yo dawg <text> so <text> - Yo Dawg Heard You (Xzibit)

inspect = require('util').inspect

module.exports = (robot)->
  unless robot.brain.data.imgflip_memes?
    robot.brain.data.imgflip_memes = [
      {
        regex: /grumpy cat ()(.*)/i,
        template_id: 6624009
      },
      {
        regex: /propose (.*) (for .*)/i,
        template_id: 37676936
      },
      {
        regex: /(yo dawg .*) (so .*)/i,
        template_id: 101716
      }
    ]

  for meme in robot.brain.data.imgflip_memes
    setupResponder robot, meme

setupResponder = (robot, meme)->
  App.respond meme.regex, (msg)->
    generateMeme msg, meme.template_id, msg.match[1], msg.match[2]

generateMeme = (msg, template_id, text0, text1)->
  username = process.env.IMGFLIP_API_USERNAME
  password = process.env.IMGFLIP_API_PASSWORD

  if (username or password) and not (username and password)
    msg.reply 'To use your own Imgflip account, you need to specify username and password!'
    return

  if not username
    username = 'imgflip_hubot'
    password = 'imgflip_hubot'

  msg.http('https://api.imgflip.com/caption_image')
  .query
    template_id: template_id,
    username: username,
    password: password,
    text0: text0,
    text1: text1
  .post() (error, res, body)->
    if error
      msg.reply "I got an error when talking to imgflip:", inspect(error)
      return

    result = JSON.parse(body)
    success = result.success
    errorMessage = result.error_message

    if not success
      msg.reply "Imgflip API request failed: #{errorMessage}"
      return

    msg.send result.data.url
