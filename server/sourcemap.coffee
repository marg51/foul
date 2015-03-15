SourceMapConsumer = require('source-map').SourceMapConsumer
fs = require('fs')
_ = require('lodash')
config = require('./config')


smc = undefined

# load the original sourcemap. Used into .consum()
# @todo something modular, automatic, git-ified
fs.readFile config.root_dir+config.sourcemap, (err, data) ->
	if err then console.log err

	smc = new SourceMapConsumer(JSON.parse(data));


# uses stack traces to return original filename/line/...
# @params <Array({lineNumber, columnNumber})>errors: stack traces from browser, should contain
# @params <String>message: error message from browser
# @return {message: String, stack: Array({line: Integer, column: Integer, functionName: String, name: String, source: String})}
exports.consum = (errors, message) ->

	# for each ref from the sourcemap, we return the original filename/line
	stack = _.map errors, (e) ->
		error = smc.originalPositionFor({line:e.lineNumber, column: e.columnNumber})
		error.functionName = e.functionName

		error

	message: message
	stack: stack
