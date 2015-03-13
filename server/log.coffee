require('colors')
fs = require('fs')
_ = require('lodash')

exports.displayFiles = (errors) ->

	_.map errors.stack, (e, i) ->
		displayFile(e, (if i is 0 then errors.message else ""))


displayFile = (stack, message="") ->
	try
		data = fs.readFileSync stack.source

		data = data.toString().split('\n')

		data[stack.line-1] = data[stack.line-1].cyan;

		data.splice(stack.line,0,(new Array(stack.column+1)).join(' ')+"• ".green.bold+message.red)

		if stack.line <= 5 then min = 1 else min = stack.line - 5

		console.log "\n",stack.source.green+':'+(stack.line+"").gray+':'+stack.functionName.cyan,"\n"
		console.log data.splice(min,10).join('\n')

	catch e 
		console.log e.stack
		