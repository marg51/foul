request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/timing/_search', json: {
  "aggs": {
    "value": {
      "terms": {
        "field": "type"
      },
      "aggs": {
        "value": {
            "terms": {
                "field": "name",
                "order": {
                    "value": "asc"
                }
            },
            "aggs": {
                "value": {
                    "avg": {
                        "field": "duration"
                    }
                }
            }
        }
      }
    }
  }
}, (err, http, body) ->
    # console.log JSON.stringify(body)
    _.map body.aggregations.value.buckets, (e) ->
        console.log e.key.magenta
        _.map e.value.buckets, (f) ->
            console.log " •".gray, f.key.cyan, ("( "+f.doc_count+" events )").gray, (Math.ceil(f.value.value*100)/100+"").yellow+"ms"
)
