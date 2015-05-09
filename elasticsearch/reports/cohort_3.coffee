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
    # return console.log JSON.stringify data.body

    result = []
    _.map data.body.aggregations.value.buckets, (f) ->
      el = {}
      el.name = f.key
      el.total_user = f.value.buckets[0].value.buckets.length
      el.data = []
      el.unit = "day"
      _.map f.value.buckets, (e) ->
        el.data.push({x:+e.key,y:e.value.buckets.length/el.total_user*100})
      # el.name  = moment(f.key).format("ddd DD, MMM YY")

      result.push(el)

    # console.log(JSON.stringify(result));

    _.map result, (e) ->
      console.log e.name.cyan, ("("+e.total_user+" signups)").yellow
      _.map e.data, (f) ->
        console.log ("day "+f.x).gray,"->",(f.y+"%").green
)
