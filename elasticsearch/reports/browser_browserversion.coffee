request = require('request')
_ = require('lodash')
require('colors')
moment = require('moment')

request.post('http://localhost:9200/foul/session/_search', json: {
  "aggs": {
    "value": {
      "nested": {
        path: "browser"
      },
      "aggs": {
        "value": {
          "terms": {
            field: "browser.family"
          },
          "aggs": {
            "value": {
                "reverse_nested": {},
                "aggs": {
                    "value": {
                        "nested": {
                            path: "os"
                        },
                        "aggs": {
                            "value": {
                                "terms": {
                                    field: "os.family"
                                },
                                "aggs": {
                                    "value": {
                                        "reverse_nested": {},
                                        "aggs": {
                                            "value": {
                                                "nested": {
                                                    path: "browser"
                                                },
                                                "aggs": {
                                                    "value": {
                                                        "terms": {
                                                            field: "browser.version"
                                                        },
                                                        "aggs": {
                                                          "value": {
                                                            "reverse_nested": {},
                                                            "aggs": {
                                                              "value": {
                                                                "nested": {
                                                                  path: "timings"
                                                                },
                                                                "aggs": {
                                                                  "value": {
                                                                    "terms": {
                                                                      field: "timings.type"
                                                                    },
                                                                    "aggs": {
                                                                      "value": {
                                                                        "terms": {
                                                                          field: "timings.name",
                                                                        },
                                                                        "aggs": {
                                                                          "value": {
                                                                            "reverse_nested": {},
                                                                            "aggs": {
                                                                              "value": {
                                                                                "terms": {
                                                                                  field: "appVersion"
                                                                                },
                                                                                "aggs": {
                                                                                  "value": {
                                                                                    "nested": {
                                                                                      path: "timings"
                                                                                    },
                                                                                    "aggs": {
                                                                                      "value": {
                                                                                        "percentiles": {
                                                                                          field: "timings.duration",
                                                                                          percents : [5, 25, 70, 99]
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
          }
        }
      }
    }
  }
}, (err, http, body) ->
    console.log JSON.stringify(body,null,2)
    _.map body.aggregations.value.value.buckets, (e) ->
        console.log e.key.cyan,"(",(e.doc_count+"").cyan,")"
        _.map e.value.value.value.buckets, (f) ->
            console.log " •", (f.key+"").magenta,"(",(f.doc_count+"").red,")"
            _.map f.value.value.value.buckets, (g) ->
              console.log "   •", (g.key+"").green,"(",(g.doc_count+"").green,")"
              _.map g.value.value.value.buckets, (h) ->
                console.log "      •", (h.key+"").magenta,"(",(h.doc_count+"").magenta,")"
                _.map h.value.buckets, (i) ->
                  console.log "         •", (i.key+"").yellow,"(",(i.doc_count+"").yellow,")"
                  _.map i.value.value.buckets, (k) ->
                    console.log "            •",k.key.cyan
                    _.map _.keys(k.value.value.values), (j) ->
                      console.log "               •", j+"% <=", ((Math.ceil(k.value.value.values[j]*100)/100)+"").green+"ms"
)
