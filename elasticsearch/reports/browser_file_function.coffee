request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/track/_search', json: {
  "aggs": {
    "browser": {
      "terms": {
        "field": "browser"
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
    _.map body.aggregations.browser.buckets, (e) ->
        console.log e.key.cyan,"(",(e.doc_count+"").cyan,")"
        _.map e.file.buckets, (f) ->
            console.log " •", (f.key+"").magenta,"(",(f.doc_count+"").red,")"
            _.map f.function.buckets, (g) ->
                console.log "   ›", (g.key+"").gray,"(",(g.doc_count+"").gray,")"
)