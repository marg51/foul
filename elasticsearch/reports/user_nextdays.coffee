request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

# which users came back the next day
request.post('http://localhost:9200/foul/session/_search', json: {
  aggs:
    value:
      terms:
        script: "_source.user.id+'_'+null"
      aggs:
        value:
          date_histogram:
            field: "date"
            interval: "day"
          # aggs:
          #   value:
          #     scripted_metric:
          #       init_script: "_agg.values = [];"
          #       map_script: """
          #         _agg.values.add(doc.date.value)
          #       """
          #       combine_script: """
          #         return _agg.values.min()
          #       """
          #       # reduce_script: """
          #       #   min=[]; values=[];for(i in _aggs) { min.add(i[0]);for(a in i[1]){values.add(i)}; };
          #       #   min = new DateTime(min.min())
          #       #   for(value in values) {

          #       #   }
          #       # """
          #     aggs:
          #       value:
          #         terms:
          #           field: "date"



}, (err, data) ->
    console.log JSON.stringify data.body
)
