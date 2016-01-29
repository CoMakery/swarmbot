swarmbot = require '../../src/models/swarmbot'

describe 'swarmbot', ->
  describe '#coluExplorerUrl', ->
    it 'is not the mangled one Glenn uses to test that Colu is down', ->
      swarmbot.coluExplorerUrl().should.eq "https://explorer.coloredcoins.org"
