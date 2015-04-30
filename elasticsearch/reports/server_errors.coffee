request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/error/_search', json: {
  query:
    filtered:
        filter:
            range:
                date:
                    gt: "now-24d"
aggs:
    value:
        terms:
            field: "type"
        aggs:
            value:
                terms:
                    field: "message"
                aggs:
                    hits:
                        top_hits:
                            size: 2
                            sort:
                                date: "desc"
                    histogram:
                        date_histogram:
                            field: "date"
                            interval: "day"
                            min_doc_count: 0
                            extended_bounds:
                                min: "now-24d"
                                max: "now"



}, (err, data) ->
    # console.log JSON.stringify data.body

    result = []
    _.map data.body.aggregations.value.buckets, (e) ->
        el = {}
        el.name = e.key
        el.count = e.doc_count
        el.events = []
        _.map e.value.buckets, (f) ->
            subel = {}
            subel.name = f.key
            subel.count = f.doc_count
            subel.hits = f.hits.hits.hits
            subel.histogram = []
            _.map f.histogram.buckets, (g) ->
                subel.histogram.push({date: g.key, count: g.doc_count})

            el.events.push(subel)
        result.push(el)

    console.log JSON.stringify result
)
