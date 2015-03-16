#!/bin/bash

x="curl http://localhost:9200"

$x/foul/route -XDELETE
$x/foul/route/_mapping -XPUT -d '{
    "properties" : {
      "session_id" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "fromState" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "toState": {
        "type": "long",
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