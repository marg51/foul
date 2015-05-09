#!/bin/bash

x="curl http://localhost:9200"

$x/foul/device -XDELETE
$x/foul/device/_mapping -XPOST -d '{
    "properties" : {
      "date": {
        "type": "date",
        "format": "dateTime"
      }
    }
  }'
