request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

# which users came back the next day
request.post('http://localhost:9200/foul/session/_search', json: {
  aggs:
    value:
      terms:
        script: "_source.user.id"
      aggs:
        value:
          scripted_metric:
            init_script: "_agg.values = [];"
            map_script: """
              _agg.values.add(doc["date"].value)
            """
            combine_script: "[_agg.values.min(),_agg.values.max()]"
            reduce_script: "min=[]; max=[];for(i in _aggs) { min.add(i[0]);max.add(i[1]); }; return Days.daysBetween(new DateTime(min.min()), new DateTime(max.max())).getDays()"


}, (err, data) ->
    console.log JSON.stringify data.body
)
