# Description:
#   Create a DCO (from Slack or any Hubut supported channel!)
#
# Dependencies:
#   None
#
# Commands:
#   hubot list dcos - list all existing DCOs (limit 10)
#   hubot list dcos XYZ - list all existing DCOs that match XYZ
#   hubot select <dco_name> (you must be the creator)
#   hubot create <dco_name> dco
#   hubot set statement of intent <statement_of_intent>
#   hubot issue X of asset - issue X of associated asset. You will need to pay Bitcoins to this address.
#   hubot send asset to <user_name>
#   hubot create constitution (creates a fork of the Citizen Code constitution)
#   hubot file dco (dynamically creates an LLC)
#   hubot open for membership for $XYZ - allow users to join membership in your DCO for a set price in USD
#   hubot open for membership for xyzBTC - allow users to join membership in your DCO) for a set price in BTC
#   hubot join <dco_name> - join a DCO, usually by agreeing to the statement of intent and paying a membership fee
#
# Author:
#   fractastical

Config          = require '../models/config'
Account          = require '../models/account'
Asset          = require '../models/asset'
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
  robot.respond /(\S+) bounty add (\S+)$/i, (msg) ->
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
