request = require('request')
_ = require('lodash')
require('colors')

request.post('http://localhost:9200/foul/track/_search', json: {
  "query" : {
      "match": {
        "category": "javascript"
      }
  },
  "aggs": {
    "value": {
      "terms": {
        "field": "type"
      },
      "aggs": {
        "value": {
          "terms": {
            "field": "category"
          },
          "aggs": {
            "value": {
              "terms": {
                "field": "file"
              },
              "aggs": {
                "value": {
                  "terms": {
                    "field": "functionName"
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
    console.log require('../toCsv')(body.aggregations)
)

request.post('http://localhost:9200/foul/track/_search', json: {
  "query" : {
      "match": {
        "category": "route"
      }
  },
  "aggs": {
    "value": {
      "terms": {
        "field": "type"
      },
      "aggs": {
        "value": {
          "terms": {
            "field": "category"
          },
          "aggs": {
            "value": {
              "terms": {
                "field": "state"
              },
              "aggs": {
                "value": {
                  "terms": {
                    "field": "stateParams.profileURN"
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
    console.log require('../toCsv')(body.aggregations)
)