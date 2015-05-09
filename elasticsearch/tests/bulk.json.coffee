console.log JSON.stringify [
  {
    "name": "route",
    "data": {
      "toState": "identify",
      "toParams": {}
    },
    "time": 176.69700004626065
  },
  {
    "name": "timing",
    "data": {
      "name": "identify",
      "type": "state",
      "duration": 120.70699996547773
    },
    "time": 297.40800004219636
  },
  {
    "name": "identify",
    "data": {
      "user": {
        "id": 8,
        "username": "utopik",
        "token": 123
      }
    },
    "time": 307.4750000378117
  },
  {
    "name": "event",
    "data": {
      "user": {
        "id": 8,
        "username": "utopik",
        "token": 123
      },
      "name": "identify",
      "type": "success",
      "message": "User successfuly identified"
    },
    "time": 307.7310000080615
  },
  {
    "name": "acquisition",
    "data": {
      "user": {
        "id": process.argv[2] || 6,
        "username": "utopik",
        "token": 123
      },
      "name": "identify",
      "type": "success",
      "message": "User successfuly identified"
    },
    "time": 307.8020000248216
  }
]
