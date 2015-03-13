request = require('request')
_ = require('lodash')
require('colors')

request.post('http://localhost:9200/foul/track/_search', json: {
  "aggs": {
    "file": {
      "terms": {
        "field": "file"
      },
      "aggs": {
          "function": {
              "terms": {
                  "field": "functionName"
              },
              "aggs": {
              "version": {
                  "terms": {
                      "field": "appVersion"
                  }
              }
          }
          }
      }
    }
  }
}, (err, http, body) -> 
  _.map body.aggregations.file.buckets, (e) ->
      console.log e.key.cyan,"(",(e.doc_count+"").cyan,")"
      _.map e.function.buckets, (f) ->
          console.log " •", (f.key+"").magenta,"(",(f.doc_count+"").red,")"
          _.map f.version.buckets, (g) ->
              console.log "   ›", (g.key+"").gray,"(",(g.doc_count+"").gray,")"
)