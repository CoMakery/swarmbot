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
      @render new IndexView {projects: @projects.all(), currentUser: @currentUser, userBalances: @userBalances}
    .error (e)=>
      @render new IndexView {projects: @projects.all(), currentUser: @currentUser, userBalances: [], coluError: e.message}

  show: ->
    @getProject()
    .then (project)=> project.fetch()
    .then (@project)=>
      (new ColuInfo).allHolders(@project)
    .then (holders)=>
      @userBalance =
        balance: (findWhere holders, { address: @currentUser.get 'btcAddress' })?.amount
        totalCoins: sum pluck holders, 'amount'
      @render new ShowView {@project, @currentUser, @userBalance}
    .error(@handleError)

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
      projectStatement: data.description
      imageUrl: data.imageUrl ? ''
      projectOwner: @currentUser.key()
      tasksUrl: data.tasksUrl
    .save()
    .then (project)=>
      project.issueAsset amount: Project::INITIAL_PROJECT_COINS
      @currentUser.set 'currentProject', project.key()

  capTable: ->
    @getProject()
    .then (project)=>
      (new ColuInfo).allHoldersWithNames(project).then (holders)=>
        debug holders
        @sendPm @render new CapTableView { project: project, capTable: holders }
        @redirect()
    .error(@handleError)

  rewardsList: (data)->
    @getProject()
    .then (@project)=>
      rewards = @project.rewards().models
      Promise.map rewards, (reward)=>
        User.find reward.get('recipient')
        .then (recipient)=>
          reward.recipientRealName = recipient.get('realName')
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
    .error(@handleError)

  suggest: ->
    @sendPm
      pretext: "You can suggest a swarmbot improvement and contribute to the betterment of all things swarmbot by submitting issues!"
      title: "Swarmbot Issues on Github"
      title_link: "https://github.com/citizencode/swarmbot/issues"
    @redirect()
module.exports = ProjectsStateController
