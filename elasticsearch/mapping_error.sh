#!/bin/bash

x="curl http://localhost:9200"

$x/foul/error/_mapping -XDELETE
$x/foul/error/_mapping -XPOST -d '{
  "_parent": {
    "type": "session"
  },
  "properties": {
    "sessionId": {
      "type": "string",
      "index": "not_analyzed"
    },
    "deviceId": {
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
    "data": {
      "type": "object",
      "properties": {
        "file": {
          "type": "string",
          "index": "not_analyzed"
        },
        "functionName": {
          "type": "string",
          "index": "not_analyzed"
        }
      }
    },
    "date": {
      "type": "date",
      "format": "dateTime"
    }
  }
}'
