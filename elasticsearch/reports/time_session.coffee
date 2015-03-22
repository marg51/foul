request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/session/_search', json: {
  "aggs": {
    "date": {
      "date_histogram": {
        "field": "date",
        "interval": "10m",
      },
      "aggs": {
        "value": {
          "top_hits": {
            "sort": [{
              "date": {
                "order": "asc"
                }
            }],
            "size" : 10
          }
        }
      }
    }
  }
}, (err, http, body) -> 
    # console.log JSON.stringify(body)
    _.map body.aggregations.date.buckets, (e) ->
        console.log moment(e.key).fromNow().green
        x = {events:0, errors: 0, routes:0, sessions: e.value.hits.hits.length}
        _.map e.value.hits.hits, (f) ->
          if f._source["events"]?
            x["events"]+= f._source.events.length
          if f._source["routes"]?
            x["routes"]+= f._source.routes.length
          if f._source["errors"]?
            x["errors"]+= f._source.errors.length

        console.log "\t•".gray, (x.sessions+" sessions").cyan
        console.log "\t•".gray, (x.events+" events").blue
        console.log "\t•".gray, (x.routes+" routes").yellow
        console.log "\t•".gray, (x.errors+" errors").magenta



)