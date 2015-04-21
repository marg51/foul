#!/bin/bash

x="curl http://localhost:9200"

$x/foul/session/_mapping -XPUT -d '{
  "properties": {
    "errors": {
      "type": "nested",
      "properties": {
          "_id": {
            "type": "string",
            "index": "not_analyzed"
          }
        }
      }
    }
}'
