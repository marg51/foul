# Foul, JavaScript tracker

[![](http://www.commitstrip.com/wp-content/uploads/2015/03/Strip-Debug-mail-650-finalenglish1.jpg)](http://www.commitstrip.com/en/2015/03/23/brace-yourself-debug-is-coming/)

Event tracker.

 - errors (http queries, javascript errors)
 - pages tracking
 - events tracking
 - timing tracking


### Realtime terminal logs


Example of use : Timing API

```
http -- time elapsed (average) for every API endpoints
 • /api/users/me ( 2 events ) 424ms
 • /api/users/:id/counters ( 2 events ) 1071ms
 • /api/users/:id/messages ( 2 events ) 1895.5ms
 • /api/users/:id/pets ( 2 events ) 2329ms
state -- time elapsed (average) for each state transition (single page application)
 • conversations ( 1 events ) 8ms
 • home ( 2 events ) 424.5ms
browserEvent -- time elapsed (average) for the page to be fully loaded
 • pageLoad ( 2 events ) 12371ms
 ```


### elasticsearch reports

![image](http://s21.postimg.org/7hyl5we1j/Screen_Shot_2015_04_12_at_12_14_03.png)

## API

#### POST /create-session

> - a new session should be created before anything else.
- A cookie `foulSessionUID` is sent to the requester and others queries should send this cookie back.
- Every `event`, `route`, `error` will be attached to this session.
- On a single page app, a new session could be created at page load (a user can have several sessions)

- `browser:String` name of browser, ie. _Firefox_
- `browserVersion:Number` version of browser, ie. _38_
- `appVersion:String` version of your app, could be a git hash.
- `prod:Boolean` if set to true, it means the session is occurring on live, not on test/dev

```bash
curl -XPOST http://localhost:3001/create-session -d '
{
  "appVersion": "1.7.4",
  "prod": false
}'

# HTTP/1.1 200 OK
# Set-Cookie: foulSessionUID=AUxCwMOJ7d1kE33QCVmW
# Date: Sun, 22 Mar 2015 18:31:11 GMT
# Connection: keep-alive
# Transfer-Encoding: chunked
```

#### POST /bulk

> be careful, the client should have the cookie from `/create-session` before doing any bulk query. It will either fail to save, either attach to a previous session if the cookie is set but outdated.

Send an array of queries.

```json
curl -XPOST 'http://localhost:3001/bulk' -H 'Cookie: foulLastErrorUID=AUzbnOm5iK_-ftvT9JT1;' --data-binary '[
  {
    "name": "route",
    "data": {
      "toState": "demo",
      "toParams": {}
    },
    "time": 156.06499999557855
  },
  {
    "name": "timing",
    "data": {
      "name": "demo",
      "type": "state",
      "duration": 68.56900000275346
    },
    "time": 224.65899999951944
  },
  {
    "name": "error",
    "data": {
      "type": "http",
      "url": "somefailedurl",
      "method": "GET",
      "statusCode": 404,
      "message": "Not Found"
    },
    "time": 242.10499999753665
  },
  {
    "name": "event",
    "data": {
      "type": "success",
      "name": "login",
      "message": "user clicked the main button on homepage"
    },
    "time": 262.15
  }
]'```

Queries can be either `route`, `timing`, `error` or `event`.

##### route

Everytime a new page/state is reached

- `toState:String` name of the new route/state
- `toParams:Object` list of params for this route/state


##### event

> an event can be anything. From the login to a click event, a submitted form …

- `name:String` name of the event
- `type:String` success|error describe the nature of the event
- `message:String` describe the event

##### error

there are different kind of errors, but they are all related to a bug somewhere.

- `type:String` is it "HTTP" error, "javascript" error
- `message:String` describe the error
- …

###### if the error is an HTTP error:

- `url:String` URL of the query
- `method:String` HTTP verb (get, post, put …)
- `name:String` canonical url (/users/13/messages -> /users/:id/messages)

###### if the error is a javascript error:

- `stack:Array` (only on chrome)

##### timing

>
- a timing can report any duration an event took — from a http query to how long the user took to fill in the form

- `name:String` name of the event. Could be an URL, or the name of a form, etc.
- `type:String` what category is it. Could be HTTP, route, user interaction, etc.
- `message:String` a humanised name + string. ie "loading of the page http://example.com/api/"
- `duration:Integer` time elapsed in **ms**.




***

## Benchmark

Core i7, 2.5Ghz

`ab -c 10 -n 100 -p /tmp/post.data -H "Cookie: foulLastRouteUID=AUxBg1tn7d1kE33QCVgx; foulSessionUID=AUxhaEB-7d1kE33QCVyJ; foulLastErrorUID=AUxBiHf57d1kE33QCVg1;" http://127.0.0.1:3001/create-route`


```javascript
Concurrency Level:      10
Time taken for tests:   0.329 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      12600 bytes
Total body sent:        30200
HTML transferred:       0 bytes
Requests per second:    303.73 [#/sec] (mean)
Time per request:       32.924 [ms] (mean)
Time per request:       3.292 [ms] (mean, across all concurrent requests)
Transfer rate:          37.37 [Kbytes/sec] received
                        89.58 kb/s sent
                        126.95 kb/s total
```

This is extremely slow but it makes sense, I'm using a new Request for every transaction with elasticsearch. Using official elasticsearch package should improve our perfs.
EDIT: It was ~200 queries per seconds, it's now 300. I changed too many things to understand why.

## Credits

Thanks to :
- NodeJS' & elasticsearch' communities
- https://github.com/bluesmoon/node-geoip
- https://github.com/3rd-Eden/useragent
- https://github.com/petkaantonov/bluebird
- https://github.com/Marak/colors.js
- https://github.com/lodash/lodash
- https://github.com/mcavage/node-restify
- https://github.com/mozilla/source-map/
- https://github.com/thlorenz/cardinal
- https://github.com/request/request
- https://github.com/mbostock/d3
