{ log, p, pjson } = require 'lightsaber'
{ merge } = require 'lodash'
ZorkView = require '../zork-view'

class CreateView extends ZorkView
  constructor: (@project, @data, {@recipient})->
    @menu = {}
    @menu.x = { transition: 'exit', text: 'exit' }
    # if only there was a better way...

    if @data.recipient? and not @data.rewardTypeId?
      for key, menuItem of @rewardTypesMenu()
        @menu[key.toLowerCase()] = menuItem if key?

  render: ->
    if not @data.recipient?
      @question "Which slack @user should I send the reward to? ('x' to exit)"
    else if not @data.rewardTypeId? # which points to a rewardType: this reward's parent
      [
        {
          pretext: "What award type?"
          fields: [
            value: @renderMenuItems @rewardTypesMenu()
          ]
        }
      ]
    else if not @data.rewardAmount?
      @question "How much do you want to reward @#{@recipient.get 'slack_username'} for \"#{@data.rewardTypeId}\""
    else if not @data.description?
      @question "What was the contribution @#{@recipient.get 'slack_username'} made for the award?"


  rewardTypesMenu: ->
    i = 0
    menu = {}
    @project.rewardTypes().map (rewardType)=>
      menu[@letters[i++]] =
        text: rewardType.get('name')
        data: merge {rewardTypeId: rewardType.key()}, @data
        command: 'setStateData'
    menu

module.exports = CreateView
