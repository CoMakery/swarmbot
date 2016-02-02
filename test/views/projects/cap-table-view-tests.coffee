{ createProject } = require '../../helpers/test-helper'
Project = require '../../../src/models/project.coffee'
CapTableView = require '../../../src/views/projects/cap-table-view.coffee'

describe 'CapTableView', ->
  describe 'render', ->
    it 'returns a string with a sweet Google chart api url', ->
      createProject()
      .then (@project)=>
        @capTable = [
          {name: 'Glenn', address: 'addy1', amount: 300},
          {name: 'Duke', address: 'addy2', amount: 400},
          {name: 'Harlan', address: 'addy3', amount: 500},
        ]

        view = new CapTableView(@project, @capTable)
        result = view.render()
        result[0].title.should.eq 'some project id'
        result[0].image_url.should.match ///https://chart.googleapis.com/chart\?///
        result[0].image_url.should.match ///chs=450x200///
        result[0].image_url.should.match ///chd=t:25,33.333333333333336,41.666666666666664///
        result[0].image_url.should.match ///cht=p3///
        result[0].image_url.should.match ///&chma=30,30,30,30///
        result[0].image_url.should.match ///chl=Glenn%2025%25|Duke%2033%25|Harlan%2042%25"///
