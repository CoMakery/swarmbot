global.Promise = require 'bluebird'  # ensure bluebird is always used instead of built-in Promise

# global debuggers, so that we have a single color for each
Debug = require 'debug'
global.debug = Debug 'app'
global.debugReply = Debug 'reply'
global.errorLog = Debug 'error'
global.inspectFallback = Debug 'fallback'

Promise.longStackTraces() if process.env.NODE_ENV is 'development' # decreases performance 5x

if process.env.AIRBRAKE_API_KEY
  airbrake = require('airbrake').createClient(process.env.AIRBRAKE_API_KEY)
  airbrake.handleExceptions()

  # catch unhandled promise rejections with Airbrake:
  process.on 'unhandledRejection', (error, promise)->
    throw error unless airbrake
    console.error 'Unhandled rejection: ' + (error and error.stack or error)
    airbrake.notify error, (airbrakeNotifyError, url)->
      if airbrakeNotifyError
        throw airbrakeNotifyError
      else
        debug "Delivered to #{url}"
        throw error

module.exports = { airbrake }
