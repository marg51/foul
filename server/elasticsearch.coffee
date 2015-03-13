request = require('request')


exports.save = (errors, data) ->

	rapport = 
		appVersion: data.version
		browser: "Chrome"
		user: data.user
		file: errors.stack[0].source
		line: errors.stack[0].line
		message: errors.message
		functionName: errors.stack[0].functionName
		date: Date.now()
		state: "Demo"
		params: "{}"


	request.post {url: 'http://localhost:9200/foul/track', json: rapport}, (err, http, body) ->
		console.log err if err