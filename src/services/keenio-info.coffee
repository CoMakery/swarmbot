Keenio = require 'keen-js'

class KeenioInfo
  projectId = process.env.KEENIO_PROJECT_ID
  writeKey = process.env.KEENIO_API_TOKEN

  constructor: (@keenioClient)->
    @keenioClient ?= new Keenio({projectId, writeKey})

  createUser: (user)->
    @keenioClient.addEvent("createUser", {
      slackUsername: user.get('slackUsername')
      emailAddress: user.get('emailAddress')
    })

module.exports = KeenioInfo
