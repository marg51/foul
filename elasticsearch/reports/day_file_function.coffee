request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/track/_search', json: {
  "aggs": {
    "date": {
      "date_histogram": {
        "field": "date",
        "interval": "day",
        "format": "yyyy-MM-dd"
      },
      "aggs": {
        "file": {
          "terms": {
            "field": "file"
          },
          "aggs": {
            "function": {
              "terms": {
                "field": "functionName"
              }
            }
          }
        }
      }
    }
  }
}, (err, http, body) -> 
    # console.log JSON.stringify(body,null,2)
    _.map body.aggregations.date.buckets, (e) ->
        console.log (moment(e.key).format("MMMM Do, hh:mm:ss")+"").cyan,"(",(e.doc_count+"").cyan,")"
        _.map e.file.buckets, (f) ->
            console.log " •", (f.key+"").magenta,"(",(f.doc_count+"").red,")"
            _.map f.function.buckets, (g) ->
                console.log "   ›", (g.key+"").gray,"(",(g.doc_count+"").gray,")"
)