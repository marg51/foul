request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/acquisition/_search?search_type=count', json: {

aggs:
  value:
    terms:
      script: "_source.session.app.features.name"
    aggs:
      value:
        histogram:
          script: """
            Days.daysBetween(new DateTime(_source.user.signup), new DateTime(_source.event.date)).getDays()
          """
          interval: 1
          min_doc_count: 0
          extended_bounds:
            min: 0
            max: 6
        aggs:
          value:
            terms:
              script: "_source.user.user.id"




}, (err, data) ->
    return console.log JSON.stringify data.body.aggregations
)
