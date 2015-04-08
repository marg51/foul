request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')


request.post('http://localhost:9200/foul/route/_search', json: {
  query:
    filtered:
      filter:
        bool:
          must_not:
            exists:
              field: "nextRouteId"
  aggs:
    value:
      terms:
        field: "toState"
        order:
          _count: "desc"

}, (err, data) ->
    # return console.log JSON.stringify data.body
    list = {}
    _.map data.body.aggregations, (e) ->
      _.map e.buckets, (f) ->
       console.log f.key, f.doc_count
)
