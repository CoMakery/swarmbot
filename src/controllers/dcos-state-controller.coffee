{ log, p, pjson } = require 'lightsaber'
ApplicationController = require './application-state-controller'
DcoCollection = require '../collections/dco-collection'

class DcosStateController extends ApplicationController

module.exports = DcosStateController
