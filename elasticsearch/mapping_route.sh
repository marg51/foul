#!/bin/bash

x="curl http://localhost:9200"

$x/foul/session/_mapping -XPUT -d '{
    "properties" : {
      "routes": {
        "type": "nested",
        "include_in_parent": true,
        "properties": {
          "session_id" : {
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
      }
    }
  }'

$x/foul/route/_mapping -XDELETE
$x/foul/route/_mapping -XPUT -d '{
  "properties": {
    "session_id" : {
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