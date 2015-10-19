{log, p, pjson} = require 'lightsaber'
chai = require 'chai'
chaiAsPromised = require("chai-as-promised")
chai.should()
chai.use(chaiAsPromised);

App = require '../app'

nock = require 'nock'
#  = require('nock').back
# nockBack.fixtures = "#{__dirname}/fixtures/"
# nockBack.setMode 'record'
nock.disableNetConnect()  # disable real http requests

# process.env.EXPRESS_PORT = 8901  # don't conflict with hubot console port 8080
process.env.FIREBASE_URL = 'https://firebase.example.com/'

describe 'swarmbot', ->
  context 'home', ->
    it "shows help upon request", ->
      msg =
        match: [null, "help"]
        robot:
          whose: (msg) -> "user:1234"
      App.route(msg).should.eventually.match ///
        \*Proposals in Jill Land\*
        1: awesome emoticons
        2: dinner at 5
        3: foo
        4: foobar
        5: Create a proposal
        6: More commands

        To take an action, simply enter the number or letter at the beginning of the line.
      ///
