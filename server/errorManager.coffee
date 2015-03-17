sourcemap = require('./sourcemap')
_ = require('lodash')
ES = require('./elasticsearch')

exports.createError = (data, cookies) ->
	errors = {}

	if(data.type is "javascript")
		errors = sourcemap.consum(data.data, data.message)


	# we create our object that we will save into elasticsearch
	object = {}

	_.merge object, _.omit(data,"data"),
		message: data.message
		data: errors,
		sessionId: cookies.foulSessionUID
		routeId: cookies.foulLastRouteUID
		previousErrorId: cookies.foulLastErrorUID
		date: Date.now()

	if errors.stack && errors.stack.length > 0
		_.merge object, 
			file: errors.stack[0].source
			line: errors.stack[0].line
			column: errors.stack[0].column
			functionName: errors.stack[0].functionName,


	# return promise
	ES.post('error', object).then (data) ->
		_.merge(object, data)