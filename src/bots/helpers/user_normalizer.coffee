class UserNormalizer
  # whole class has been deprecated
  
  # @normalizationEnabled: ->
  #   'HUBOT_TEAM_NORMALIZE_USERNAMES' of process.env
  #
  # @normalize: (username, userInput)->
  #   if userInput and userInput.toLocaleLowerCase() isnt 'me'
  #     username = userInput
  #   if @normalizationEnabled()
  #     '@' + username.replace /@*/g, ''
  #   else
  #     username
  #
  # @currentUser: (message) ->
  #   "@#{message.message.user.id}"

module.exports = UserNormalizer
