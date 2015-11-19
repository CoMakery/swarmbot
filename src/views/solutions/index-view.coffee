{ log, p, pjson } = require 'lightsaber'
{ merge } = require 'lodash'
ZorkView = require '../zork-view'

class IndexView extends ZorkView
  constructor: (@proposal) ->
    @solutionItems = {}
    @actionItems = {}

    i = 0
    @proposal.solutions().sortBy('totalVotes').each (solution) =>
      @solutionItems[@letters[i++]] =
        text: solution.get('name').toLowerCase()
        transition: 'show'
        data: { solutionId: solution.key(), proposalId: solution.parent.key() }

    i = 0
    @actionItems[i++] = { text: "« back", transition: 'exit', data: {proposalId: @proposal.key()} }
    @actionItems[i++] = { text: "submit a solution", transition: 'create', data: {proposalId: @proposal.key()} }

    @menu = merge {}, @actionItems
    for key, item of @solutionItems
      @menu[key.toLowerCase()] = item

  render: ->
    fallbackText = """
    *#{if @proposal.solutions().isEmpty() then 'No solutions' else 'Solutions'} for #{@proposal.key()}*

    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

    [
      {
        color: '#33F'
        title: "community » #{(@proposal.parent.get 'name').toLowerCase()} » #{@proposal.get('name').toLowerCase()} » solutions"
      }
      {
        color: '#66BB66'
        title: (@proposal.get 'name').toUpperCase()
        fields: [
          {
            title: 'Solutions'
            value: if @solutionItems.length == 0
                "There are no solutions yet for this proposal."
              else
                @renderMenuItems(@solutionItems)
          }
        ]
        fallback: fallbackText
      }
      {
        color: '#FB6'
        fields: [
          {
            title: 'Actions'
            value: @renderMenuItems(@actionItems)
          }
        ]
      }
    ]

module.exports = IndexView
