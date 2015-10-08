{ log, p, pjson } = require 'lightsaber'

class ProposalsStateController
  constructor: (@router, @msg) ->
    @user = @msg.currentUser

  process: ->
    p "Processing proposals state", @msg.match[1], @user.current

    switch @user.current
      when 'home'
        switch @msg.match[1]
          when '1'
            @user.show(1)
            @router.route(@msg)
          when '2' then p 2
          when '0' then @user.exit()

      when 'proposals-index'
        switch @msg.match[1]
          when '1' then @show(1)
          when '2' then p 2
          when '0' then @user.exit()

      when 'proposals-show'
        switch @msg.match[1]
          when '1' then @show(1)
          when '0' then @user.exit(); @router.route(@msg)

  show: (proposalId) ->

    p 'showing ' + proposalId

module.exports = ProposalsStateController
