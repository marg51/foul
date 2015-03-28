request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/session/_search', json: {
  "aggs": {
    "value": {
      "terms": {
        "field": "userId"
      }
    }
  }
}, (err, http, body) ->
    _.map body.aggregations.value.buckets, (e) ->
        console.log ("UserId: " + e.key).cyan, "( "+ (e.doc_count+"").magenta, "sessions )"
)
