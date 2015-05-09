#!/bin/bash

x="curl http://localhost:9200"

$x/foul/session -XDELETE
$x/foul/session/_mapping -XPOST -d '{
    "properties" : {
      "app": {
        "type": "object",
        "properties": {
          "version" : {
            "type" : "string",
            "index": "not_analyzed"
          },
          "name": {
            "type": "string",
            "index": "not_analyzed"
          },
          "hash" : {
            "type" : "string",
            "index": "not_analyzed"
          },
          "env" : {
            "type" : "string",
            "index": "not_analyzed"
          },
          "features": {
            "type": "object",
            "properties": {
              "name": {
                "type": "string",
                "index": "not_analyzed"
              }
            }
          }
        }
      },
      "user_id" : {
        "type": "string",
        "index": "not_analyzed"
      },
      "location": {
        "type": "object",
        "properties": {
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
          }
        }
      },
      "device": {
        "type": "object",
        "properties": {
          "browser": {
            "type": "object",
            "properties": {
              "family": {
                "type": "string",
                "index": "not_analyzed"
              },
              "version": {
                "type": "string",
                "index": "not_analyzed"
              },
              "major": {
                "type": "short"
              },
              "minor": {
                "type": "short"
              },
              "patch": {
                "type": "short"
              }
            }
          },
          "os": {
            "type": "object",
            "properties": {
              "family": {
                "type": "string",
                "index": "not_analyzed"
              },
              "version": {
                "type": "string",
                "index": "not_analyzed"
              },
              "major": {
                "type": "short"
              },
              "minor": {
                "type": "short"
              },
              "patch": {
                "type": "short"
              }
            }
          },
          "device": {
            "type": "object",
            "properties": {
              "family": {
                "type": "string",
                "index": "not_analyzed"
              },
              "version": {
                "type": "string",
                "index": "not_analyzed"
              },
              "major": {
                "type": "short"
              },
              "minor": {
                "type": "short"
              },
              "patch": {
                "type": "short"
              }
            }
          }
        }
      },
      "deviceId": {
        "type": "string",
        "index": "not_analyzed"
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
