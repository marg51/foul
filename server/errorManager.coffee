sourcemap = require('./sourcemap')

exports.createError = (data) ->

	errors = sourcemap.consum(data.data, data.message)

	# we create our object that we will save into elasticsearch
	object = {}

	_.merge object, _.omit(req.params,"data"),
		file: errors.stack[0].source
		line: errors.stack[0].line
		column: errors.stack[0].column
		message: errors.message
		functionName: errors.stack[0].functionName,
		data: errors

	# return promise
	ES.post('error', object)