request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/route/_search', json: {
  "aggs": {
    "value": {
      "terms": {
        "field": "sessionId"
      },
      "aggs": {
        "value": {
          "terms": {
            "field": "date"
          },
          "aggs": {
            "value": {
              "terms": {
                "field": "toState"
              }
            }
          }
        }
      }
    }
  }
}, (err, http, body) -> 
    map = []
    _.map body.aggregations, (e) ->
      _.map e.buckets, (f) ->
        x = []
        _.map f.value.buckets, (g) ->
          _.map g.value.buckets, (h) ->
            x.push(h.key)

        x.push('leave')
        map.push(x.join('#'))

    _.map _.groupBy(map), (e, i)-> console.log i+","+e.length
#       e.value.buckets[0]
#       _.map(e.value.buckets[0])
#     console.log require('../toCsv')(_.map body.aggregations, (e)-> )


#     _.map body.aggregations.value.buckets, (e) ->
#         console.log e.key.cyan,"(",(e.doc_count+"").cyan,")"
#         _.map e.value.buckets, (f) ->
#             console.log " •", (f.key+"").magenta,"(",(f.doc_count+"").red,")"
#             _.map f.value.buckets, (g) ->
#               console.log " •", (g.key+"").gray,"(",(g.doc_count+"").gray,")"
)