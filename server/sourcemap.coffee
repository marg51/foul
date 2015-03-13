SourceMapConsumer = require('source-map').SourceMapConsumer
fs = require('fs')
_ = require('lodash')


smc = undefined

fs.readFile 'app.js.map', (err, data) ->
	if err then console.log err

	smc = new SourceMapConsumer(JSON.parse(data));



exports.consum = (errors, message) ->

	stack = _.map errors, (e) ->
		error = smc.originalPositionFor({line:e.lineNumber, column: e.columnNumber})
		error.functionName = e.functionName

		error

	message: message
	stack: stack
