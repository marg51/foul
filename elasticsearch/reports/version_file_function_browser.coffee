request = require('request')
_ = require('lodash')
require('colors')

request.post('http://localhost:9200/foul/track/_search', json: {
  "aggs": {
    "file": {
      "terms": {
        "field": "appVersion"
      },
      "aggs": {
          "function": {
              "terms": {
                  "field": "file"
              },
              "aggs": {
              "version": {
                  "terms": {
                      "field": "functionName"
                  },
                  "aggs": {
                      "browser": {
                          "terms": {
                              "field": "browser"
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
  console.log (body.took+"ms").green.underline
  _.map body.aggregations.file.buckets, (e) ->
      console.log e.key.cyan,"(",(e.doc_count+"").cyan,")"
      _.map e.function.buckets, (f) ->
          console.log " •", (f.key+"").magenta,"(",(f.doc_count+"").red,")"
          _.map f.version.buckets, (g) ->
              console.log "   ›", (g.key+"").white,"(",(g.doc_count+"").white,")"
              _.map g.browser.buckets, (h) ->
                  console.log "      ›", (h.key+"").gray,"(",(h.doc_count+"").gray,")"
)