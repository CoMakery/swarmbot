{ log, p, pjson } = require 'lightsaber'
{ isEmpty, clone } = require 'lodash'
ZorkView = require '../zork-view'
User = require '../../models/user'

class ShowView extends ZorkView
  constructor: (@award, { canSetBounty })->
    @solutionItems = {}
    i = 0
    @award.rewards().sortBy('totalVotes').each (solution)=>
      @solutionItems[@letters[i++]] =
        text: solution.get('name').toLowerCase()
        transition: 'show'
        data: { solutionId: solution.key(), awardId: solution.parent.key() }

    @menuItems = {}
    i = 1

    @menuItems[i++] =
      text: "all projects"
      teleport: User::initialState

    @menuItems[i++] =
      text: "vote up"
      command: 'upvote'
      data: { awardId: @award.key() }

    # @menuItems[i++] =
    #   text: "view all solutions",
    #   transition: 'solutions'
    #   data: { awardId: @award.key() }

    @menuItems[i++] =
      text: "submit new solution",
      transition: 'createSolution'
      data: { awardId: @award.key() }

    if canSetBounty
      @menuItems[i++] =
        text: "set reward",
        transition: 'setBounty'
        data: { awardId: @award.key() }

    @menu = clone @menuItems
    for key, item of @solutionItems
      @menu[key.toLowerCase()] = item

  render: ->
    description = ''
    if not isEmpty @award.get('description')
      description += "_#{@award.get('description')}_\n"
    if amount = @award.get 'amount'
      description += "Reward: #{amount}\n"
    if imageUrl = @award.get 'imageUrl'
      description += "Image: #{imageUrl}\n"

    fields = [
      {
        title: 'Solutions'
        value: @renderMenuItems @solutionItems
        short: true
      }
    ]
    if amount = @award.get 'amount'
      fields.push {
        title: 'Reward'
        value: amount
        short: true
      }
      fields.push {short: true}

    fields.push {
      title: 'Actions'
      value: @renderMenuItems @menuItems
      short: true
    }

    [
      {
        color: @NAV_COLOR
        title: "project » #{(@award.parent.get 'name').toLowerCase()} » #{(@award.get 'name').toLowerCase()}"
      }
      {
        color: @BODY_COLOR
        title: (@award.get 'name').toUpperCase()
        text: @award.get('description')
        thumb_url: @award.get 'imageUrl'
        fallback: """
          *Task: #{@award.get 'name'}*
          #{description}
          """
      }
      {
        color: @ACTION_COLOR
        fields: fields
        fallback: @renderMenu()
      }
    ]

module.exports = ShowView
