#!/bin/bash

x="curl http://localhost:9200"

$x/foul/event/_mapping -XDELETE
$x/foul/event/_mapping -XPOST -d '{
  "_parent": {
    "type": "user"
  },
  "properties" : {
    "sessionId" : {
      "type" : "string",
      "index": "not_analyzed"
    },
    "deviceId" : {
      "type" : "string",
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
    }
  }
}'
