request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/session/_search', json: {
  aggs:
    value:
      terms:
        script: """
            route = []
            for (i in _source.routes)
              route.add(i.toState)
            return route.join('#') + "#leave"
        """




}, (err, data) ->
    console.log "• normal".green
    _.map data.body.aggregations, (e) ->
        _.map e.buckets, (f) ->
            console.log f.key+','+f.doc_count
)

request.post('http://localhost:9200/foul/session/_search', json: {
  aggs:
    value:
      terms:
        script: """
            route = []
            for (i in _source.routes.reverse())
              route.add(i.toState)
            return route.join('#')+'#joining'
        """




}, (err, data) ->
    console.log "• reversed".green
    _.map data.body.aggregations, (e) ->
        _.map e.buckets, (f) ->
            console.log f.key+','+f.doc_count
)
