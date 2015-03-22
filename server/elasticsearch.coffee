request = require('request')
Promise = require("bluebird")
require('colors')
_ = require('lodash')
log = require('./log')


# save our <Object>rapport into elasticsearch.
# exports.save = (rapport) ->

#   rapport.date = Date.now()

#   request.post {url: 'http://localhost:9200/foul/track', json: rapport}, (err, http, body) ->
#       console.log err if err
#       # if elasticsearch return an error, we console.log it
#       if body.status is 400
#           console.log JSON.stringify(body, 4, null)


handleResponse = (resolver, body) ->
    if(body.status is 400) 
        resolver.reject(body)
    else if body.found is false
        resolver.reject(body)
    else
        if !body._type 
            body = JSON.parse(body)

        log.displayESQuery '[RESOLVED]\t'.magenta,body._type,body._id,"\n"
        resolver.resolve(body)

exports.post = (name, data) ->
    resolver = Promise.pending()

    request.post  {url: "http://localhost:9200/foul/#{name}", json: data}, (err, http, body) ->
        log.displayESQuery "POST\t\t".green, name.yellow
        return handleResponse(resolver, body)

    resolver.promise.catch (data) ->
       console.log data

       throw new Error(data)


exports.get = (name, id) ->
    resolver = Promise.pending()

    request.get  {url: "http://localhost:9200/foul/#{name}/#{id}"}, (err, http, body) ->
        log.displayESQuery "GET\t\t".green, name.yellow, id
        return handleResponse(resolver, body)

    resolver.promise.catch (data) ->
       console.log data

       throw new Error(data)


exports.put = (name, id, data) ->
    resolver = Promise.pending()

    request.put  {url: "http://localhost:9200/foul/#{name}/#{id}", json: data}, (err, http, body) ->
        log.displayESQuery "PUT\t\t".green, name.yellow, id
        return handleResponse(resolver, body)

    resolver.promise.catch (data) ->
       console.log data

       throw new Error(data)
