{ log, p, pjson } = require 'lightsaber'
{ isEmpty } = require 'lodash'
ZorkView = require '../zork-view'

class ShowView extends ZorkView
  constructor: (@proposal, { canSetBounty }) ->
    @menu = {}
    i = 0

    @menu[i++] = { text: "« back", transition: 'exit' }

    @menu[i++] =
      text: "vote up"
      command: 'upvote'
      data: { proposalId: @proposal.key() }

    @menu[i++] =
      text: "view all solutions",
      transition: 'solutions'
      data: { proposalId: @proposal.key() }

    @menu[i++] =
      text: "submit solution",
      transition: 'createSolution'
      data: { proposalId: @proposal.key() }

    if canSetBounty
      @menu[i++] =
        text: "set reward",
        transition: 'setBounty'
        data: { proposalId: @proposal.key() }


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
        title: 'Actions'
        value: @renderMenu()
        short: true
      }
    ]
    if amount = @proposal.get 'amount'
      fields.push {
        title: 'Reward'
        value: amount
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
