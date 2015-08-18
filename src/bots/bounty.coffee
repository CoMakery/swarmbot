# Description:
#   Create a bounty
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_TEAM_ADMIN - A comma separate list of user names
#
# Commands:
#   hubot create <bounty_name> bounty X coins - create bounty called <bounty_name> with X coins
#   hubot list bounties - list all existing bounties
#   hubot award <bounty_name> bounty to <username>  - award an existing bounty
#   hubot (<bounty_name>) bounty add me - add me to the bounty

#
# Author:
#   fractastical, mihai

# Not displayed in help
##   hubot (<bounty_name>) bounty add (me|<user>) - add me or <user> to bounty
##   hubot (<bounty_name>) bounty add (me|<user>) - add me or <user> to bounty
##   hubot (<bounty_name>) bounty remove (me|<user>) - remove me or <user> from bounty
##   hubot (<bounty_name>) bounty (empty|clear) - clear bounty list
##   hubot (delete|remove) <bounty_name> bounty - delete bounty called <bounty_name>
##   hubot (<bounty_name>) bounty -1 - remove me from the bounty
##   hubot (<bounty_name>) bounty count - list the current size of the bounty
##   hubot (<bounty_name>) bounty (list|show) - list the people in the bounty


Config          = require '../models/config'
Bounty          = require '../models/bounty'
Account          = require '../models/account'
ResponseMessage = require './helpers/response_message'
UserNormalizer  = require './helpers/user_normalizer'

module.exports = (robot) ->
  robot.brain.data.bounties or= {}
  Bounty.robot = Account.robot = robot

  # unless Config.adminList()
  #   robot.logger.warning 'HUBOT_TEAM_ADMIN environment variable not set'


  ##
  ## hubot create <bounty_name> bounty - create bounty called <bounty_name>
  ##
  robot.respond /create (\S*) bounty (\S*) coins?.*/i, (msg) ->

    bountyName = msg.match[1]
    bountySize = msg.match[2]
    if bounty = Bounty.get bountyName
      message = ResponseMessage.bountyAlreadyExists bounty
    else
      bounty = Bounty.create bountyName, bountySize
      message = ResponseMessage.bountyCreated bounty
    msg.send message

  ##
  ## hubot create <bounty_name> bounty - create bounty called <bounty_name>
  ##
  robot.respond /award (\S*) bounty to (\S*).*/i, (msg) ->

    bountyName = msg.match[1]
    awardee = msg.match[2]
    message = "Awarding bounty to " + msg.match[2]

    bountySize = Bounty.getBountySize(bountyName)
    activeUser = UserNormalizer.normalize(msg.message.user.name)
    Account.updateAccountBalance(activeUser, -bountySize)
    Account.updateAccountBalance(awardee, bountySize)

    msg.send message

  ##
  ## hubot (delete|remove) <bounty_name> bounty - delete bounty called <bounty_name>
  ##
  robot.respond /(delete|remove) (\S*) bounty ?.*/i, (msg) ->
    bountyName = msg.match[2]
    if Config.isAdmin(msg.message.user.name)
      if bounty = Bounty.get bountyName
        bounty.destroy()
        message = ResponseMessage.bountyDeleted bounty
      else
        message = ResponseMessage.bountyNotFound bountyName
      msg.send message
    else
      msg.reply ResponseMessage.adminRequired()


  ##
  ## hubot list bounties - list all existing bounties
  ##
  robot.respond /list bounties ?.*/i, (msg) ->
    bounties = Bounty.all()
    msg.send ResponseMessage.listBountys bounties

  ##
  ## hubot <bounty_name> bounty add (me|<user>) - add me or <user> to bounty
  ##
  robot.respond /(\S*)? bounty add (\S*) ?.*/i, (msg) ->
    bountyName = msg.match[1]
    bounty = Bounty.getOrDefault(bountyName)
    return msg.send ResponseMessage.bountyNotFound(bountyName) unless bounty
    user = UserNormalizer.normalize(msg.message.user.name, msg.match[2])
    isMemberAdded = bounty.addMember user
    if isMemberAdded
      message = ResponseMessage.memberAddedToBounty(user, bounty)
    else
      message = ResponseMessage.memberAlreadyAddedToBounty(user, bounty)
    msg.send message

  ##
  ## hubot <bounty_name> bounty +1 - add me to the bounty
  ##
  robot.respond /(\S*)? bounty add me?.*/i, (msg) ->
    bountyName = msg.match[1]
    bounty = Bounty.getOrDefault(bountyName)
    return msg.send ResponseMessage.bountyNotFound(bountyName) unless bounty
    user = UserNormalizer.normalize(msg.message.user.name)
    isMemberAdded = bounty.addMember user
    if isMemberAdded
      message = ResponseMessage.memberAddedToBounty(user, bounty)
    else
      message = ResponseMessage.memberAlreadyAddedToBounty(user, bounty)
    msg.send message

  ##
  ## hubot <bounty_name> bounty remove (me|<user>) - remove me or <user> from bounty
  ##
  robot.respond /(\S*)? bounty remove (\S*) ?.*/i, (msg) ->
    bountyName = msg.match[1]
    bounty = Bounty.getOrDefault(bountyName)
    return msg.send ResponseMessage.bountyNotFound(bountyName) unless bounty
    user = UserNormalizer.normalize(msg.message.user.name, msg.match[2])
    isMemberRemoved = bounty.removeMember user
    if isMemberRemoved
      message = ResponseMessage.memberRemovedFromBounty(user, bounty)
    else
      message = ResponseMessage.memberAlreadyOutOfBounty(user, bounty)
    msg.send message

  ##
  ## hubot <bounty_name> bounty -1 - remove me from the bounty
  ##
  robot.respond /(\S*)? bounty -1/i, (msg) ->
    bountyName = msg.match[1]
    bounty = Bounty.getOrDefault(bountyName)
    return msg.send ResponseMessage.bountyNotFound(bountyName) unless bounty
    user = UserNormalizer.normalize(msg.message.user.name)
    isMemberRemoved = bounty.removeMember user
    if isMemberRemoved
      message = ResponseMessage.memberRemovedFromBounty(user, bounty)
    else
      message = ResponseMessage.memberAlreadyOutOfBounty(user, bounty)
    msg.send message

  ##
  ## hubot <bounty_name> bounty count - list the current size of the bounty
  ##
  robot.respond /(\S*)? bounty count$/i, (msg) ->
    bountyName = msg.match[1]
    bounty = Bounty.getOrDefault(bountyName)
    message = if bounty then ResponseMessage.bountyCount(bounty) else ResponseMessage.bountyNotFound(bountyName)
    msg.send message

  ##
  ## hubot <bounty_name> bounty (list|show) - list the people in the bounty
  ##
  robot.respond /(\S*)? bounty (list|show)$/i, (msg) ->
    bountyName = msg.match[1]
    bounty = Bounty.getOrDefault(bountyName)
    message = if bounty then ResponseMessage.listBounty(bounty) else ResponseMessage.bountyNotFound(bountyName)
    msg.send message

  ##
  ## hubot <bounty_name> bounty (empty|clear) - clear bounty list
  ##
  robot.respond /(\S*)? bounty (clear|empty)$/i, (msg) ->
    if Config.isAdmin(msg.message.user.name)
      bountyName = msg.match[1]
      if bounty = Bounty.getOrDefault bountyName
        bounty.clear()
        message = ResponseMessage.bountyCleared bounty
      else
        message = ResponseMessage.bountyNotFound bountyName
      msg.send message
    else
      msg.reply ResponseMessage.adminRequired()

  ##
  ## hubot upgrade bounties - upgrade bounty for the new structure
  ##
  robot.respond /upgrade bounties$/i, (msg) ->
    bounties = {}
    for index, bounty of robot.brain.data.bounties
      if bounty instanceof Array
        bounties[index] = new Bounty index, bounty
      else
        bounties[index] = bounty

    robot.brain.data.bounties = bounties
    msg.send ResponseMessage.listBountys Bounty.all()
