#!/bin/bash

x="curl http://localhost:9200"

$x/foul/error -XDELETE
$x/foul/error/_mapping -XPUT -d '{
    "properties" : {
      "session_id" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "route_id" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "type": {
        "type": "long",
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