request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

# http://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-metrics-top-hits-aggregation.html
request.post('http://localhost:9200/foul/_search', json: {
  "query": {
    "range": {
      "date": {
        "gte": "now-1h"
      }
    }
  },
  "aggs": {
    "value": {
      "terms": {
        "field": "sessionId",
      },
      "aggs": {
        "value": {
          "top_hits": {
            "sort": [{
              "date": {
                "order": "asc"
                }
              }
            ]
            "size" : 10
          }
        }
      }
    }
  },
  "size": 30
}, (err, http, body) -> 
    console.log JSON.stringify(body,null,2)
    _.map body.aggregations.value.buckets, (e) ->
        console.log "\n",e.key.blue,"( ",(e.doc_count+" events").gray,")"
        _.map e.value.hits.hits, (g, i, a) ->
            if i is 0
              date = moment(g._source.date).format("MMMM Do, HH:mm:ss")
            else 
              date = parseInt((g._source.date - a[i-1]._source.date)/1000) + " seconds later"
            if g._type is "error"
              text = " • [".gray+"ERROR".magenta+"(".gray+g._source.type.cyan+")]".gray
              if g._source.type is "http"
                text += (" "+g._source.statusCode+" "+g._source.message).magenta + " "+g._source.url.gray
              else if g._source.type is "javascript"
                if g._source.file
                  text += " "+g._source.file+':'+g._source.line+'#'+g._source.functionName
            else if g._type is "event"
              if g._source.type is "success"
                text = " • [".gray+"EVENT".green+"(".gray+g._source.name.cyan+")]".gray
              else
                text = " • [".gray+"EVENT".red+"(".gray+g._source.name.cyan+")]".gray

              text += " "+(g._source.message||"")

            else if g._type is "route"
              text = "[".gray+"STATECHANGE".green+"(".gray+g._source.toState.cyan+")]".gray
              text += " "+JSON.stringify(g._source.toParams)


            console.log " •", text, date.gray
            # else if g._type is "route"
            #   console.log " •", "["+g._source.toState.gray+"]", "change to new state", date
            # else if g._type is "event"
            #   console.log " •", (g._source.name+"").green, "new event", date
            # else 
            #   console.log " •", (g._type+"").gray, date
)