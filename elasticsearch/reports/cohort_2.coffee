request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/session/_search', json: {
  aggs:
    value:
      terms:
        field: "appVersion"
      aggs:
        value:
          terms:
            script: """
                Minutes.minutesBetween(doc['date'].date, doc['updatedAt'].date).getMinutes()
            """




}, (err, data) ->
    return console.log JSON.stringify data.body.aggregations

    result = []
    _.map data.body.aggregations.value.buckets, (f) ->
      el       = {}
      el.name  = moment(f.key).format("ddd DD, MMM YY")
      el.range = [0,10]
      el.total = f.doc_count
      el.data  = []

      totalSignedIn = 0

      _.map f.value.buckets, (e) ->
        if e.key is "-1"
          console.log (e.doc_count+" people never signed in").red, ((Math.round(e.doc_count/data.body.hits.total*100)) + "%").gray
        else if e.key < el.range[1]
          totalSignedIn += e.doc_count
          el.data.push({signin: Math.round(totalSignedIn/el.total*100), time: +e.key+1})
          console.log (totalSignedIn+" people signed in after "+e.key+" minutes").green, ((Math.round(totalSignedIn/el.total*100)) + "%").gray

      result.push(el)

    console.log JSON.stringify result
)

# Minutes.minutesBetween(doc['date'].date, doc['updatedAt'].date).getMinutes()

# script: """
#           if (_source.routes.size() < 3)
#             return "NA"
#           else
#             return _source.routes.get(_source.routes.size()-1).toState +"-"+ _source.routes.get(_source.routes.size()-2).toState+"-"+ _source.routes.get(_source.routes.size()-3).toState
#         """

# script: """
#           if (_source.routes.size() < 2)
#             return "NA"
#           else
#             route = []
#             for (i in _source.routes)
#               route.add(i.toState)
#             return route.join('-')
#         """

  # aggs:
  #   value:
  #     scripted_metric:
  #       init_script: "_agg.values = []"
  #       map_script: """
  #         _agg.values.add(Minutes.minutesBetween(doc['date'].date, DateTime.now()).getMinutes())
  #       """
  #       combine_script: "profit = 0; for (t in _agg.values) { profit += t }; return profit"
  #       reduce_script: "profit = 0; for (a in _aggs) { profit += a }; return profit"

