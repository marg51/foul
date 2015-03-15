request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/track/_search', json: {
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
}, (err, http, body) -> 
    # console.log JSON.stringify(body,null,2)
    _.map body.aggregations.value.buckets, (e) ->
        console.log e.key.cyan,"(",(e.doc_count+"").cyan,")"
        _.map e.value.buckets, (f) ->
            console.log " •", (f.key+"").magenta,"(",(f.doc_count+"").red,")"
)