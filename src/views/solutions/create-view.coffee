{ log, p, pjson } = require 'lightsaber'
{ merge } = require 'lodash'
ZorkView = require '../zork-view'

class CreateView extends ZorkView
  constructor: (@dco, @data, {@recipient})->
    @menu = {}
    @menu.x = { transition: 'exit', text: 'exit' }
    # if only there was a better way...

    if @data.recipient? and not @data.awardId?
      for key, menuItem of @awardsMenu()
        @menu[key.toLowerCase()] = menuItem if key?

  render: ->
    if not @data.recipient?
      @question "Which slack @user should I send the reward to? ('x' to exit)"
    else if not @data.awardId? # which points to a award: this solution's parent
      [
        {
          pretext: "What award type?"
          fields: [
            value: @renderMenuItems @awardsMenu()
          ]
        }
      ]
    else if not @data.rewardAmount?
      @question "How much do you want to reward @#{@recipient.get 'slack_username'} for \"#{@data.awardId}\""
    else if not @data.description?
      @question "What was the contribution @#{@recipient.get 'slack_username'} made for the award?"


  awardsMenu: ->
    i = 0
    menu = {}
    @dco.awards().map (award)=>
      menu[@letters[i++]] =
        text: award.get('name')
        data: merge {awardId: award.key()}, @data
        command: 'setStateData'
    menu

module.exports = CreateView
