request = require('request')
Promise = require("bluebird")

_ = require('lodash')


# save our <Object>rapport into elasticsearch.
# exports.save = (rapport) ->

# 	rapport.date = Date.now()

# 	request.post {url: 'http://localhost:9200/foul/track', json: rapport}, (err, http, body) ->
# 		console.log err if err
# 		# if elasticsearch return an error, we console.log it
# 		if body.status is 400
# 			console.log JSON.stringify(body, 4, null)


handleResponse = (resolver, body) ->
	if(body.status is 400) 
		resolver.reject(body)
	else resolver.resolve(body)

exports.post = (name, data) ->
	resolver = Promise.pending()

	request.post  {url: "http://localhost:9200/foul/#{name}", json: data}, (err, http, body) ->
		return handleResponse(resolver, body)

	resolver.promise.catch (data) ->
       console.log data

       throw new Error(data)


exports.get = (name, data) ->
	resolver = Promise.pending()

	request.get  {url: "http://localhost:9200/foul/#{name}", json: data}, (err, http, body) ->
		return handleResponse(resolver, body)

	resolver.promise
