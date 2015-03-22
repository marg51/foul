#!/bin/bash

x="curl http://localhost:9200"

$x/foul/session/_mapping -XPUT -d '{
    "properties" : {
      "errors": {
        "type": "nested",
        "properties": {
          "session_id" : {
            "type" : "string",
            "index": "not_analyzed"
          },
          "route_id" : {
            "type" : "string",
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

$x/foul/error/_mapping -XDELETE
$x/foul/error/_mapping -XPOST -d '{
  "properties": {
    "session_id": {
      "type": "string",
      "index": "not_analyzed"
    },
    "route_id": {
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
      "type": "nested",
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