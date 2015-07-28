class ResponseMessage

  bountyCreated: (bounty)->
    "#{bounty.label()} created with #{bounty.size} coins"

  bountyAlreadyExists: (bounty)->
    "#{bounty.label()} already exists"

  bountyDeleted: (bounty)->
    "#{bounty.label()} removed"

  listBountys: (bountys)->
    return 'No bounty was created so far' if bountys.length is 0
    message = "Bounties:\n"

    for bounty in bountys
      if bounty.membersCount() > 0
        message += "`#{bounty.name}` #{bounty.size} coins (#{bounty.membersCount()} total)"

        for user in bounty.members
          message += "\n- #{user}"
      else
        message += "`#{bounty.name}` #{bounty.size} coins  (unassigned)\n"
    message

  listCurrencies: (currencies)->
    return 'No currency was created so far' if bountys.length is 0
    message = "Currencies:\n"

    for currency in currencies
        message += "`#{currency.name}` #{currency.unites} coins"

    message

  adminRequired: -> "Sorry, only admins can perform this operation"

  memberAddedToBounty: (member, bounty)->
    count = bounty.membersCount() - 1
    message = "#{member} added to the #{bounty.label()}"
    return message if count is 0
    singular_or_plural = if count is 1 then "other is" else "others are"
    "#{message}, #{count} #{singular_or_plural} in"

  memberAlreadyAddedToBounty: (member, bounty)->
    "#{member} already in the #{bounty.label()}"

  memberRemovedFromBounty: (member, bounty)->
    count = bounty.membersCount()
    message = "#{member} removed from the #{bounty.label()}"
    return message if count is 0
    "#{message}, #{count} remaining"

  memberAlreadyOutOfBounty: (member, bounty)->
    "#{member} already out of the #{bounty.label()}"

  bountyCount: (bounty)->
    "#{bounty.membersCount()} people are currently in the bounty"

  bountyNotFound: (bountyName)->
    "`#{bountyName}` bounty does not exist"

  listBounty: (bounty)->
    count = bounty.membersCount()
    if count is 0
      response = "There is no one in the #{bounty.label()} currently"
    else
      position = 0
      response = "#{bounty.label()} (#{count} total):\n"
      for member in bounty.members
        position += 1
        response += "#{position}. #{member}\n"

    response

  bountyCleared: (bounty)->
    "#{bounty.label()} list cleared"

module.exports = new ResponseMessage
