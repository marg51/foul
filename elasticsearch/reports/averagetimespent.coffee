request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/session/_search', json: {
  aggs:
    value:
      date_histogram:
        field: "date"
        interval: "day"
      aggs:
        value:
          avg:
            script: """
              if (_source.routes.size()>0)
                return Seconds.secondsBetween(doc['date'].date, new DateTime(_source.routes.get(_source.routes.size()-1).date)).getSeconds()
              else
                return 0
            """
        perc:
          percentiles:
            script: """
              if (_source.routes.size()>0)
                return Seconds.secondsBetween(doc['date'].date, new DateTime(_source.routes.get(_source.routes.size()-1).date)).getSeconds()
              else
                return 0
            """
            percents : [5, 15, 30, 50, 70, 85, 95]

}, (err, data) ->
    # console.log JSON.stringify data.body
    console.log "—","Bouncing state per day".toUpperCase().underline.green,"—"
    result = []
    _.map data.body.aggregations.value.buckets, (e) ->
      console.log " •".green, moment(e.key).format("ddd DD, MMM YY").magenta
      result.push
        name: moment(e.key).format("ddd DD, MMM YY")
        avg: (Math.round(e.value.value*100)/100)
        data: [{
          x: 5
          y: (Math.round(e.perc.values["5.0"]))
        }, {
          x: 15
          y: (Math.round(e.perc.values["15.0"]))
        }, {
          x: 30
          y: (Math.round(e.perc.values["30.0"]))
        }, {
          x: 50
          y: (Math.round(e.perc.values["50.0"]))
        }, {
          x: 70
          y: (Math.round(e.perc.values["70.0"]))
        }, {
          x: 85
          y: (Math.round(e.perc.values["85.0"]))
        }, {
          x: 95
          y: (Math.round(e.perc.values["95.0"]))
        }]
      console.log "  avg \t ›".gray, ((Math.round(e.value.value        /60*100)/100)+"m").yellow
      console.log "  15% \t ›".gray, ((Math.round(e.perc.values["15.0"]/60*100)/100)+"m").yellow
      console.log "  50% \t ›".gray, ((Math.round(e.perc.values["50.0"]/60*100)/100)+"m").yellow
      console.log "  85% \t ›".gray, ((Math.round(e.perc.values["85.0"]/60*100)/100)+"m").yellow

    console.log "\n", JSON.stringify result
)
