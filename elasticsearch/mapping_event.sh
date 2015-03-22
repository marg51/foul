#!/bin/bash

x="curl http://localhost:9200"

$x/foul/session/_mapping -XPUT -d '{
  "properties": {
    "events": {
      "type": "nested",
        "properties" : {
          "session_id" : {
            "type" : "string",
            "index": "not_analyzed"
          },
          "route_id" : {
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
      }
    }
  }'

$x/foul/event/_mapping -XDELETE
$x/foul/event/_mapping -XPOST -d '{
  "properties" : {
    "session_id" : {
      "type" : "string",
      "index": "not_analyzed"
    },
    "route_id" : {
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