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
                    "value.25": "asc"
                }
            },
            "aggs": {
                "value": {
                    "percentiles": {
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
            console.log " •".gray, f.key.cyan, ("( "+f.doc_count+" events )").gray
            _.forEach f.value.values, (e, i) ->
                console.log "    -".gray, (i+"%").green, (e+"").yellow+"ms"

)
