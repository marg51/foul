#!/bin/bash

x="curl http://localhost:9200"

$x/foul/user -XDELETE
$x/foul/user/_mapping -XPOST -d '{
    "properties" : {
      "id": {
        "type": "string",
        "index": "not_analyzed"
      },
      "date": {
        "type": "date",
        "format": "dateTime"
      },
      "dates": {
        "type": "object",
        "properties": {
          "first_visit": {
            "type": "date",
            "format": "dateTime"
          },
          "signup": {
            "type": "date",
            "format": "dateTime"
          }
        }
      }
    }
  }'


$x/foul/user/user_unknown -XPOST -d '{"id":-1}'
