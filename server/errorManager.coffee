sourcemap = require('./sourcemap')
_ = require('lodash')
ES = require('./elasticsearch')

exports.createError = (data, cookies) ->

	errors = sourcemap.consum(data.data, data.message)

	# we create our object that we will save into elasticsearch
	object = {}

	_.merge object, _.omit(data,"data"),
		file: errors.stack[0].source
		line: errors.stack[0].line
		column: errors.stack[0].column
		message: errors.message
		functionName: errors.stack[0].functionName,
		data: errors,
		sessionId: cookies.foulSessionUID

	# return promise
	ES.post('error', object).then (data) ->
		_.merge(object, data)