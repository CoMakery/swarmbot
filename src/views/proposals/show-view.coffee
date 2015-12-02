{ log, p, pjson } = require 'lightsaber'
{ isEmpty, clone } = require 'lodash'
ZorkView = require '../zork-view'
User = require '../../models/user'

class ShowView extends ZorkView
  constructor: (@proposal, { canSetBounty }) ->
    @solutionItems = {}
    i = 0
    @proposal.solutions().sortBy('totalVotes').each (solution) =>
      @solutionItems[@letters[i++]] =
        text: solution.get('name').toLowerCase()
        transition: 'show'
        data: { solutionId: solution.key(), proposalId: solution.parent.key() }

    @menuItems = {}
    i = 1

    @menuItems[i++] =
      text: "all projects"
      teleport: User::initialState

    @menuItems[i++] =
      text: "vote up"
      command: 'upvote'
      data: { proposalId: @proposal.key() }

    # @menuItems[i++] =
    #   text: "view all solutions",
    #   transition: 'solutions'
    #   data: { proposalId: @proposal.key() }

    @menuItems[i++] =
      text: "submit new solution",
      transition: 'createSolution'
      data: { proposalId: @proposal.key() }

    if canSetBounty
      @menuItems[i++] =
        text: "set reward",
        transition: 'setBounty'
        data: { proposalId: @proposal.key() }

    @menu = clone @menuItems
    for key, item of @solutionItems
      @menu[key.toLowerCase()] = item

  render: ->
    description = ''
    if not isEmpty @proposal.get('description')
      description += "_#{@proposal.get('description')}_\n"
    if amount = @proposal.get 'amount'
      description += "Reward: #{amount}\n"
    if imageUrl = @proposal.get 'imageUrl'
      description += "Image: #{imageUrl}\n"

    fields = [
      {
        title: 'Solutions'
        value: @renderMenuItems @solutionItems
        short: true
      }
    ]
    if amount = @proposal.get 'amount'
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
        title: "project » #{(@proposal.parent.get 'name').toLowerCase()} » #{(@proposal.get 'name').toLowerCase()}"
      }
      {
        color: @BODY_COLOR
        title: (@proposal.get 'name').toUpperCase()
        text: @proposal.get('description')
        thumb_url: @proposal.get 'imageUrl'
        fallback: """
          *Task: #{@proposal.get 'name'}*
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
