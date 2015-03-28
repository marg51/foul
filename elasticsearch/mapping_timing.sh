#!/bin/bash

x="curl http://localhost:9200"

$x/foul/timing/_mapping -XDELETE
$x/foul/timing/_mapping -XPOST -d '{
  "properties": {
    "session_id": {
      "type": "string",
      "index": "not_analyzed"
    },
    "routeId": {
      "type": "string",
      "index": "not_analyzed"
    },
    "name": {
      "type": "string",
      "index": "not_analyzed"
    },
    "type": {
      "type": "string",
      "index": "not_analyzed"
    },
    "message": {
      "type": "string",
      "index": "not_analyzed"
    },
    "date": {
      "type": "date",
      "format": "dateTime"
    },
    "duration": {
      "type": "long"
    }
  }
}'
