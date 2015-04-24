#!/bin/bash

x="curl http://localhost:9200"

$x/foul/session -XDELETE
$x/foul/session/_mapping -XPOST -d '{
    "properties" : {
      "appVersion" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "appHash" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "appEnv" : {
        "type" : "string",
        "index": "not_analyzed"
      },
      "user" : {
        "type": "nested",
        "properties": {
          "id": {
            "type" : "long",
            "index": "not_analyzed"
          }
        }
      },
      "location": {
        "type" : "geo_point"
      },
      "city": {
        "type": "string",
        "index": "not_analyzed"
      },
      "country": {
        "type": "string",
        "index": "not_analyzed"
      },
      "region": {
        "type": "string",
        "index": "not_analyzed"
      },
      "browser": {
        "type": "nested",
        "properties": {
          "family": {
            "type": "string",
            "index": "not_analyzed"
          },
          "version": {
            "type": "string",
            "index": "not_analyzed"
          }
        }
      },
      "device": {
        "type": "nested",
        "properties": {
          "family": {
            "type": "string",
            "index": "not_analyzed"
          },
          "version": {
            "type": "string",
            "index": "not_analyzed"
          }
        }
      },
      "os": {
        "type": "nested",
        "properties": {
          "family": {
            "type": "string",
            "index": "not_analyzed"
          },
          "version": {
            "type": "string",
            "index": "not_analyzed"
          }
        }
      },
      "date": {
        "type": "date",
        "format": "dateTime"
      },
      "updatedAt": {
        "type": "date",
        "format": "dateTime"
      }
    }
  }'
