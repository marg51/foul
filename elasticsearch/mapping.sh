#!/bin/bash

x="curl http://localhost:9200"

$x/foul -XDELETE
$x/foul/ -XPUT -d '{
"mappings": {
  "track" : {
    "properties" : {
      "appVersion" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "browser" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "user" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "date": {
        "type": "date",
        "format": "dateOptionalTime"
      },
      "file" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "line" : {
        "type" : "long",
        "index": "not_analyzed"
      },
      "column" : {
        "type" : "long",
        "index": "not_analyzed"
      },
      "functionName" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "state" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "params" : {
        "type" : "string",
        "index": "not_analyzed"
      }
    }
  }
}
}'

# $x/foul/track -XPOST -d '{
#   "browser": "Chrome",
#   "user": "laurent@tailster.com",
#   "message": "$scope.wtf is not a function",
#   "file": "/app/demo/DemoCtrl.js",
#   "line": 140,
#   "column": 15,
#   "functionName": "Scope.e.dashSearch",
#   "state": "demo",
#   "params": "{}"

# }'