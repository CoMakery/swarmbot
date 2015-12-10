{ log, p, pjson } = require 'lightsaber'
{ merge } = require 'lodash'
ZorkView = require '../zork-view'

class IndexView extends ZorkView
  constructor: (@award)->
    @solutionItems = {}
    @actionItems = {}

    i = 0
    @award.rewards().sortBy('totalVotes').each (solution)=>
      @solutionItems[@letters[i++]] =
        text: solution.get('name')?.toLowerCase()
        transition: 'show'
        data: { solutionId: solution.key(), awardId: solution.parent.key() }

    i = 0
    @actionItems[i++] = { text: "« back", transition: 'exit', data: {awardId: @award.key()} }
    @actionItems[i++] = { text: "submit a solution", transition: 'create', data: {awardId: @award.key()} }

    @menu = merge {}, @actionItems
    for key, item of @solutionItems
      @menu[key.toLowerCase()] = item

  render: ->
    fallbackText = """
    *#{if @award.rewards().isEmpty() then 'No solutions' else 'Solutions'} for #{@award.key()}*

    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

    [
      {
        color: @NAV_COLOR
        title: "project » #{(@award.parent.get 'name').toLowerCase()} » #{@award.get('name').toLowerCase()} » solutions"
      }
      {
        color: @BODY_COLOR
        title: (@award.get 'name').toUpperCase()
        fields: [
          {
            title: 'Solutions'
            value: if @solutionItems.length == 0
                "There are no solutions yet for this task."
              else
                @renderMenuItems(@solutionItems)
          }
        ]
        fallback: fallbackText
      }
      {
        color: @ACTION_COLOR
        fields: [
          {
            title: 'Actions'
            value: @renderMenuItems(@actionItems)
          }
        ]
      }
    ]

module.exports = IndexView
