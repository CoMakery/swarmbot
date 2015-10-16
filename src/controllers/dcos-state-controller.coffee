{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './state-application-controller'
DcoCollection = require '../collections/dco-collection'

class DcosStateController extends ApplicationController

module.exports = DcosStateController
