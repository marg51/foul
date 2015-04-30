#!/bin/bash

x="curl http://localhost:9200"

$x/foul/timing/_mapping -XDELETE
$x/foul/timing/_mapping -XPOST -d '{
  "properties": {
    "sessionId": {
      "type": "string",
      "index": "not_analyzed"
    },
    "deviceId": {
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
