request = require('request')
_ = require('lodash')
require('colors')

request.post('http://localhost:9200/foul/track/_search', json: {
  "aggs": {
    "value": {
      "terms": {
        "field": "appVersion"
      },
      "aggs": {
        "value": {
          "terms": {
            "field": "file"
          },
          "aggs": {
            "value": {
              "terms": {
                "field": "functionName"
              },
              "aggs": {
                "value": {
                  "terms": {
                    "field": "browser"
                  },
                  "aggs": {
                    "value": {
                      "terms": {
                        "field": "browserVersion"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}, (err, http, body) -> 
  _.map body.aggregations.value.buckets, (e) ->
      console.log e.key.cyan,"(",(e.doc_count+"").cyan,")"
      _.map e.value.buckets, (f) ->
          console.log " •", (f.key+"").magenta,"(",(f.doc_count+"").red,")"
          _.map f.value.buckets, (g) ->
              console.log "   ›", (g.key+"").white,"(",(g.doc_count+"").white,")"
              _.map g.value.buckets, (h) ->
                  console.log "      ›", (h.key+"").gray,"(",(h.doc_count+"").gray,")"

    console.log require('../toCsv')(body.aggregations)
)