request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

# request.post('http://localhost:9200/foul/session/_search', json: {
#   "aggs": {
#     "value": {
#       "children": {
#         "type": "route"
#       },
#       "aggs": {
#         "value": {
#           "terms": {
#             "field": "route.toState"
#           }
#         }
#       }
#     }
#   }
# }, (err, http, body) -> 
#     console.log JSON.stringify(body)
#     # _.map body.aggregations.date.buckets, (e) ->
#     #     console.log (moment(e.key).format("MMMM Do, HH:mm:ss")+"").cyan,"(",(e.doc_count+"").red,")"


# )


request.post('http://localhost:9200/foul/route/_search', json: {
  "query": {
    "has_parent": {
      "type": "session", 
      "query": {
        "match_all": {}
      }
    }
  }
}, (err, http, body) -> 
    console.log JSON.stringify(body)
    # _.map body.aggregations.date.buckets, (e) ->
    #     console.log (moment(e.key).format("MMMM Do, HH:mm:ss")+"").cyan,"(",(e.doc_count+"").red,")"


)