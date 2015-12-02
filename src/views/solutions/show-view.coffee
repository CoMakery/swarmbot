{ log, p, pjson } = require 'lightsaber'
{ isEmpty } = require 'lodash'
ZorkView = require '../zork-view'

class ShowView extends ZorkView
  constructor: (@solution, currentUser)->
    @menu = {}
    i = 0
    @menu[i++] = { text: "« back", transition: 'exit', data: { proposalId: @solution.parent.key() } }

    @menu[i++] =
      text: "vote up"
      command: 'upvote'
      data:
        solutionId: @solution.key()
        solutionName: @solution.get('name')
        proposalId: @solution.parent.key()

    if @solution.parent.parent.get('project_owner') is currentUser.key()
      @menu[i++] =
        text: "send reward"
        transition: 'sendReward'
        data:
          solutionId: @solution.key()
          solutionName: @solution.get('name')
          proposalId: @solution.parent.key()


  render: ->
    fallbackText = """
    *Solution: #{@solution.key()}*
    #{@solution.get('link')}

    #{@renderMenu()}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

    [
      {
        color: @NAV_COLOR
        title: "project » #{(@solution.parent.parent.get 'name').toLowerCase()} » #{@solution.parent.get('name').toLowerCase()} » #{@solution.get('name').toLowerCase()}"
      }
      {
        color: @BODY_COLOR
        title: (@solution.get 'name').toUpperCase()
        title_link: @solution.get 'link'
        unfurl_links: true
        fallback: fallbackText
      }
      {
        color: @ACTION_COLOR
        fields: [
          {
            title: 'Actions'
            value: @renderMenu()
          }
        ]
      }
    ]

module.exports = ShowView
