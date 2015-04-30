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
              "isMaster": {
                "type": "boolean"
              },
              "isSplitTesting": {
                "type": "boolean"
              }
            }
          }
        }
      },
      "user" : {
        "type": "object",
        "properties": {
          "id": {
            "type" : "string",
            "index": "not_analyzed"
          },
          "esId": {
            "type": "string",
            "index": "not_analyzed"
          },
          "fist_visit": {
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
      },
      "errors": {
        "type": "nested",
        "properties": {
          "sessionId": {
            "type": "string",
            "index": "not_analyzed"
          },
          "deviceId": {
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
          "data": {
            "type": "object",
            "properties": {
              "file": {
                "type": "string",
                "index": "not_analyzed"
              },
              "functionName": {
                "type": "string",
                "index": "not_analyzed"
              }
            }
          },
          "date": {
            "type": "date",
            "format": "dateTime"
          }
        }
      },
      "routes": {
        "type": "nested",
        "properties": {
          "sessionId" : {
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
      },
      "events": {
        "type": "nested",
        "properties" : {
          "sessionId" : {
            "type" : "string",
            "index": "not_analyzed"
          },
          "deviceId" : {
            "type" : "string",
            "index": "not_analyzed"
          },
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
          }
        }
      },
      "timing": {
        "type": "nested",
        "properties": {
          "sessionId": {
            "type": "string",
            "index": "not_analyzed"
          },
          "deviceId": {
            "type": "string",
            "index": "not_analyzed"
          },
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
          "duration": {
            "type": "long"
          }
        }
      }
    }
  }'
