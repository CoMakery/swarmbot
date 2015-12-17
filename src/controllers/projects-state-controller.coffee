debug = require('debug')('app')
{ log, p, pjson } = require 'lightsaber'
{ map, findWhere, sum, pluck } = require 'lodash'
Promise = require 'bluebird'
swarmbot = require '../models/swarmbot'
ApplicationController = require './application-state-controller'
ColuInfo = require '../services/colu-info'
Project = require '../models/project.coffee'
User = require '../models/user'
RewardTypeCollection = require '../collections/reward-type-collection'
ProjectCollection = require '../collections/project-collection'
IndexView = require '../views/projects/index-view'
CreateView = require '../views/projects/create-view'
ShowView = require '../views/projects/show-view'
ListRewardsView = require '../views/projects/list-rewards-view'
CapTableView = require '../views/projects/cap-table-view'

class ProjectsStateController extends ApplicationController
  index: ->
    ProjectCollection.all()
    .then (@projects)=>
      (new ColuInfo).balances(@currentUser)
    .then (@userBalances)=>
      debug @userBalances
      @render new IndexView {@projects, @currentUser, @userBalances}

  show: ->
    @getProject()
    .then (project)=> project.fetch()
    .then (@project)=>
      (new ColuInfo).allHolders(@project)
    .then (holders)=>
      @userBalance =
        balance: (findWhere holders, { address: @currentUser.get 'btc_address' })?.amount
        totalCoins: sum pluck holders, 'amount'
      @render new ShowView {@project, @currentUser, @userBalance}
    .error(@_showError)

  # set Project
  setProjectTo: (data)->
    @currentUser.setProjectTo(data.id).then =>
      @currentUser.exit()
      @redirect()

  create: (data={})->
    if not @input
      # fall through to render template
    else if not data.name
      data.name = @input
    else if not data.description
      data.description = @input
    else if not data.tasksUrl
      data.tasksUrl = @input
    else #if not data.imageUrl
      promise = @parseImageUrl().then (imageUrl)=>
        if imageUrl then data.imageUrl = imageUrl else data.ignoreImage = true
        @saveProject data
        .then (project)=> @project = project

    ( promise ? Promise.resolve() )
    .error (opError)=> @errorMessage = opError.message
    .then => @currentUser.set 'stateData', data
    .then =>
      if @project?
        @execute transition: 'showProject', flashMessage: 'Project created!'
      else
        @render new CreateView data, {@errorMessage}

  saveProject: (data)->
    new Project
      name: data.name
      project_statement: data.description
      imageUrl: data.imageUrl ? ''
      project_owner: @currentUser.key()
      tasksUrl: data.tasksUrl
    .save()
    .then (project)=>
      project.issueAsset amount: Project::INITIAL_PROJECT_COINS
      @currentUser.set 'current_project', project.key()

  capTable: ->
    @getProject().then (project)=>
      (new ColuInfo).allHoldersWithNames(project).then (holders)=>
        debug holders
        @sendPm @render new CapTableView { project: project, capTable: holders }
        @redirect()


  rewardsList: (data)->
    @getProject()
    .then (@project)=>
      rewards = @project.rewards().models
      Promise.map rewards, (reward)=>
        User.find reward.get('recipient')
        .then (recipient)=>
          reward.recipientRealName = recipient.get('real_name')
          reward
    .then (rewards)=>
      view  = new ListRewardsView
        project: @project
        rewards: rewards
        rewardTypes: @project.rewardTypes()
      @sendPm(@render(view))
      @currentUser.exit()
    .then =>
      @redirect()

  suggest: ->
    @sendPm
      pretext: "You can suggest a swarmbot improvement and contribute to the betterment of all things swarmbot by submitting issues!"
      title: "Swarmbot Issues on Github"
      title_link: "https://github.com/citizencode/swarmbot/issues"
    @redirect()
module.exports = ProjectsStateController
