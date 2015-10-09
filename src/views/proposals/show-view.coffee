{ log, p, pjson } = require 'lightsaber'

class ShowView
  constructor: (@proposal) ->

  build: ->

  render: ->
    """
    #{@proposal.get('id')}
    #{('-' for [0...@proposal.get('id').length]).join('')}
    -------------
    #{lines.join("\n")}

    To take an action, simply enter the number or letter at the beginning of the line.
    """

module.exports = ShowView
