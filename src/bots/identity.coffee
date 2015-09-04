# Description:
#   User / account managemnet
#
# Dependencies:
#   None
##
# Commands:
#   hubot register

#
# Author:
#   fractastical


Config          = require '../models/config'
Account          = require '../models/account'
Asset          = require '../models/asset'
ResponseMessage = require './helpers/response_message'
UserNormalizer  = require './helpers/user_normalizer'
fs = require('fs')
ColoAccess = require('colu-access')

privateSeed = 'c507290be50bca9b887af39019f80e3f9f27e4020ee0a4fe51595ee4424d6151'
apiKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJkYXZpZCIsImV4cCI6IjIwMTUtMDktMDlUMjI6NTI6MDIuMDA1WiJ9.qmoqZvdFLg0r6TPUsb4lrPGjqZfDo5B72gSNILv98kM'
settings =
  privateSeed: privateSeed
  apiKey: apiKey
  companyName: 'My company'
  network: 'mainnet'
coluAccess = new ColoAccess(settings)

module.exports = (robot) ->
  robot.DCO.data.bounties or= {}
  Account.robot = robot

  # unless Config.adminList()
  #   robot.logger.warning 'HUBOT_TEAM_ADMIN environment variable not set'


  ##
  ## hubot create <bounty_name> bounty - create bounty called <bounty_name>
  ##
  robot.respond /register/i, (msg) ->

        coluAccess.on 'connect', ->
          # This is your private seed, keep it safe!!!
          msg.send 'seed: ' + coluAccess.colu.hdwallet.getPrivateSeed()
          console.log 'seed: ' + coluAccess.colu.hdwallet.getPrivateSeed()
          username = msg.message.user.name
          registrationMessage = coluAccess.createRegistrationMessage(username)
          # You can create your own complicated qr code, or you can generate a simplified code and get it back from us in a callback.
          # var qr = coluAccess.createRegistrationQR(registrationMessage)
          coluAccess.getRegistrationQR registrationMessage, (err, code, qr) ->
            # You can use the QR in your site using it as src of img tag:
            # '<img src="'  +  qr  +  '" alt="Scan Me" height="200" width="200">'
            # or you can write it to a file like that:

            decodeBase64Image = (dataString) ->
              matches = dataString.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/)
              response = {}
              if matches.length != 3
                return new Error('Invalid input string')
              response.type = matches[1]
              response.data = new Buffer(matches[2], 'base64')
              response

            if err
              return console.error('error: ' + err)
            imageBuffer = decodeBase64Image(qr)
            filename = 'qr.jpg'
            fs.writeFile filename, imageBuffer.data, (err) ->
              # fs.writeFile(filename, new Buffer(qr, "base64"), function (err) {
              if err
                console.error err
              return
            # Now you can show the QR to the user to scan, and prompt our server for an answer when the user register successfully:
            coluAccess.registerUser {
              registrationMessage: registrationMessage
              code: code
            }, (err, data) ->
              if err
                return console.log('Error: ' + JSON.stringify(err))
              console.log 'data:' + JSON.stringify(data)
              process.exit()
              return
            return
          return
        coluAccess.init()
