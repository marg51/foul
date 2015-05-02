#!/bin/bash

x="curl http://localhost:9200"

$x/foul/route/_mapping -XDELETE
$x/foul/route/_mapping -XPUT -d '{
  "_parent": {
    "type": "session"
  },
  "properties": {
    "sessionId" : {
      "type" : "string",
      "index": "not_analyzed"
    },
    "deviceId" : {
      "type" : "string",
      "index": "not_analyzed"
    },
    "fromState" : {
      "type" : "string",
      "index": "not_analyzed"
    },
    "toState": {
      "type": "string",
      "index": "not_analyzed"
    },
    "time_elapsed" : {
      "type" : "long",
      "index": "not_analyzed"
    },
    "date": {
      "type": "date",
      "format": "dateTime"
    }
  }
}'
