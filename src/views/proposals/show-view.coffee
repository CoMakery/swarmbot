{ log, p, pjson } = require 'lightsaber'

class ShowView
  constructor: (@proposal) ->
    @menu = {
      1: { text: "Vote Up", command: 'voteUp' }
      2: { text: "Vote Down", command: 'voteDown' }
      'x': { text: "Exit", transition: 'exit' }
    }

  render: ->
    lines = for i, menuItem of @menu
      "#{i}: #{menuItem.text}"

    """
    *#{@proposal.get('id')}*
    #{lines.join("\n")}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

module.exports = ShowView
