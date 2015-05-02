#!/bin/bash

x="curl http://localhost:9200"

# mix between session / user / event

$x/foul/acquisition -XDELETE
$x/foul/acquisition/_mapping -XPOST -d '{
    "properties" : {
      "name": {
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
      "date": {
        "type": "date",
        "format": "dateTime"
      },
      "session": {
        "type": "object",
        "properties": {

        }
      },
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
      "user" : {
        "type": "object",
        "properties": {
          "user": {
            "type": "object",
            "properties": {
              "id": {
                "type": "string",
                "index": "not_analyzed"
              }
            }
          },
          "first_visit": {
            "type": "date",
            "format": "dateTime"
          },
          "signup": {
            "type": "date",
            "format": "dateTime"
          }
        }
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
