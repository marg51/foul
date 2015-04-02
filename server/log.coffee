require('colors')
fs = require('fs')
_ = require('lodash')
cdl = require('cardinal')
config = require('./config')

exports.displayFiles = (errors) ->

	console.log errors.message.magenta.bgWhite
	_.map errors.stack, (e, i) ->
		if e.source
			displayFile(e, (if i is 0 then errors.message else ""))


displayFile = (stack, message="") ->
	try
		data = cdl.highlightFileSync config.root_dir+stack.source, linenos: true
		data = data.toString().split('\n')

		line = data[stack.line-1].split(':')

		# CURSOR ALIGNEMENT
		# The goal is to place the error exactly where the error occured

		# reuse indent from previous line (both tab and space count as one char …)
		indent = line[1].match(/^(\s*)/)[0]

		# ie. if the line added by cardinal is 100, we add 3 + 1 chars so that the line number doesn't screw our alignment (+1 because of the colon)
		line_number_indent = (stack.line+"").length + 1

		# how many chars do we still have to add ?
		indentBy = stack.column + 3 + line_number_indent - indent.length
		if indentBy < 0
			indentBy = 1

		console.log stack.column,line_number_indent,indent.length
		# we add a background color to the target line
		data[stack.line-1] = line.shift()+":".white+line.join('').bgMagenta

		console.log(indentBy, line_number_indent, indent)

		# we create a new line after the error to display the message at the same column the error starts
		data.splice(stack.line,0,(indent + new Array(indentBy).join(' ')+"^ ".green.bold+message.red))

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

