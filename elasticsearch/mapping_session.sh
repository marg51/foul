#!/bin/bash

x="curl http://localhost:9200"

$x/foul/session -XDELETE
$x/foul/session/_mapping -XPUT -d '{
    "properties" : {
      "appVersion" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "browser" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "browserVersion": {
        "type": "long",
        "index": "not_analyzed"
      },
      "user_id" : {
        "type" : "long",
        "index": "not_analyzed"
      },
      "date": {
        "type": "date",
        "format": "dateTime"
      }      
    }
  }'