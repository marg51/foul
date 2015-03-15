request = require('request')
_ = require('lodash')


# save our <Object>rapport into elasticsearch.
exports.save = (rapport) ->

	rapport.date = Date.now()

	request.post {url: 'http://localhost:9200/foul/track', json: rapport}, (err, http, body) ->
		console.log err if err
		# if elasticsearch return an error, we console.log it
		if body.status is 400
			console.log JSON.stringify(body, 4, null)