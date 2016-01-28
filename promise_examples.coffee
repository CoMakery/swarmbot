Promise = require 'bluebird'

new Promise (resolve, reject)->
	reject(new Error("this is an error"))
.then ->
	console.log("this then is skipped")
.catch (e)->
	console.log("first catch #{e.message}")
.finally ->
	console.log("finally always runs")
.then ->
	console.log("this then runs because we caught above")
.finally ->
	console.log("finally always runs")
.then ->
	console.log("this then chains off a finally")
.catch (e)->
	console.log("this doesn't run because there is no error")


p = new Promise (resolve, reject)->
	p.cancel()
.then ->
	console.log("this shouldn't be seen because we canceled")
.catch Promise.CancellationError, ->
  console.log('this is the final cancelled message')
.cancellable()
	
