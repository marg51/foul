#!/bin/bash

x="curl http://localhost:9200"

$x/foul/track/_search -d '{
  "aggs": {
    "file": {
      "terms": {
        "field": "file"
      },
      "aggs": {
      	"function": {
      		"terms": {
      			"field": "functionName"
      		}
      	}
      }
    }
  }
}'