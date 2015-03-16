require('colors')
fs = require('fs')
_ = require('lodash')
cdl = require('cardinal')
config = require('./config')

exports.displayFiles = (errors) ->

	console.log errors
	console.log errors.message.magenta.bgWhite
	_.map errors.data.stack, (e, i) ->
		displayFile(e, (if i is 0 then errors.message else ""))


displayFile = (stack, message="") ->
	try
		data = cdl.highlightFileSync config.root_dir+stack.source, linenos: true
		data = data.toString().split('\n')

		line = data[stack.line-1].split(':')

		# we add a background color to the target line
		data[stack.line-1] = line.shift()+":".gray+line.join('').bgMagenta

		# we create a new line after the error to display the message at the same column the error starts
		data.splice(stack.line,0,(new Array(stack.column+(stack.line+"").length+3)).join(' ')+"• ".green.bold+message.red)

		# what first line do we want to display ? 
		# from 5 line before the error, if available
		if stack.line <= 5 then min = 0 else min = stack.line - 5

		# display the file name, the line, the upper function
		console.log "\n",stack.source.green+':'+(stack.line+"").gray+':'+(stack.functionName+"").cyan,"\n"

		# display 10 lines of the colored file
		# @todo display only 5lines after the error. 
		# If the error occurs into the first 5lines, it will display 6+ lines after the error
		console.log data.splice(min,10).join('\n')

	catch e 
		console.log e.stack
		