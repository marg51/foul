request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/session/_search', json: {
  "aggs": {
    "value": {
      "terms": {
        "field": "userId"
      }
    }
  }
}, (err, http, body) -> 
    console.log JSON.stringify(body)
    _.map body.aggregations.value.buckets, (e) ->
        console.log (moment(e.key).format("MMMM Do, HH:mm:ss")+"").cyan,"(",(e.doc_count+"").red,")"


)