request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/route/_search', json: {
  "aggs": {
    "value": {
      "terms": {
        "field": "sessionId",
        size: 100
      },
      "aggs": {
        "value": {
          "top_hits": {
            "size": 1,
            "sort": {
              "date": "asc"
            }
          },
        }
      }
    },
  },

}, (err, data) ->
    list = {}
    _.map data.body.aggregations, (e) ->
      _.map e.buckets, (f) ->
        # console.log f.key.magenta, (f.doc_count + " routes").gray, moment(f.value.hits.hits[0].sort[0]).fromNow().green
        _.map f.value.hits.hits, (g) ->
          list[g._source.toState] = (list[g._source.toState]||0) + 1
          # console.log " •", (g._source.toState||"").yellow, (JSON.stringify(g._source.toParams)||"").gray

    array = []
    _.map _.keys(list), (e) ->
      array.push([e, list[e]])

    _.map _.sortBy(array, (e) -> e[1]), (e) ->
      console.log (e[1]+"\t").yellow, e[0].green
)
