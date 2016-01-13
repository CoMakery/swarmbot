Keenio = require 'keen-js'

class KeenioInfo

  constructor: (@keenioClient)->
    projectId = process.env.KEENIO_PROJECT_ID
    writeKey = process.env.KEENIO_API_TOKEN
    if projectId and writeKey
      @keenioClient ?= new Keenio {projectId, writeKey}

  createUser: (user)->
    return unless @keenioClient?
    keenProps =
      slackUsername: user.get('slackUsername')
      emailAddress: user.get('emailAddress')
    keenProps.server = process.env.APP_NAME if process.env.APP_NAME
    debug {keenProps}
    @keenioClient.addEvent "createUser", keenProps

module.exports = KeenioInfo
