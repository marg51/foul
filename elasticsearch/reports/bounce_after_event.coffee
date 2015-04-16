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
          terms:
            script: """
              if (_source.routes.size()>0)
                return _source.routes.get(_source.routes.size()-1).toState
              else
                return 'NA'
            """,
            order:
              _count: "desc"
            size: 3

}, (err, data) ->
    console.log JSON.stringify data.body.took
    console.log "—","Bouncing state per day".toUpperCase().underline,"—"
    _.map data.body.aggregations.value.buckets, (e) ->
      console.log " •".green, moment(e.key).format("ddd DD, MMM YY").magenta
      _.map e.value.buckets, (f) ->
        console.log "  ›".gray, f.key.cyan, (f.doc_count+"").yellow
)
