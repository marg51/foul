#!/bin/bash

x="curl http://localhost:9200"

$x/foul/session/_search -d '{
   "query": {
        "bool": {
            "must": [{
                "nested": {
                    "path": "routes",
                    "query": {
                        "match": {
                            "routes.toState": "home"
                        }
                    }
                }
            }]
        }
   }
}'