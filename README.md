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

![image](https://s3-eu-west-1.amazonaws.com/uploads-eu.hipchat.com/106644/786095/X36wM0KRMcUwW4A/Screen%20Shot%202015-03-18%20at%2021.46.46.png)

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
  "browser": "Chrome",
  "browserVersion": "43",
  "appVersion": "1.7.4",
  "prod": false
}'

# HTTP/1.1 200 OK
# Set-Cookie: foulSessionUID=AUxCwMOJ7d1kE33QCVmW
# Date: Sun, 22 Mar 2015 18:31:11 GMT
# Connection: keep-alive
# Transfer-Encoding: chunked
```


#### POST /create-route

>
  - a new route should be created when the user change the page, or change of state (SPA)
  - it is linked to the previously created session (via cookie)
  - it can be linked to the previous route (via cookie)
  - it creates a new cookie `foulLastRouteUID` that could be used to link event together

- `toState:String` name of the new route/state
- `toParams:Object` list of params for this route/state

```bash
curl -XPOST http://localhost:3001/create-route -H "Cookie: foulSessionUID=AUxCwMOJ7d1kE33QCVmW" -d '
{
  "toState": "demo",
  "toParams": {}
}'

# HTTP/1.1 200 OK
# Set-Cookie: foulLastRouteUID=AUxCwMOJ7d1kE33QCVmW
# Date: Sun, 22 Mar 2015 18:39:13 GMT
# Connection: keep-alive
# Transfer-Encoding: chunked
```

#### POST /create-event

>
  - an event can be anything. From the login to a click event
  - it's linked to the session via cookie
  - it can be linked to a route via cookie

- `name:String` name of the event
- `type:String` success|error describe the nature of the event
- `message:String` describe the event
- as always, you can pass extra data, ie. userId

```bash
curl -XPOST http://localhost:3001/create-route -H "Cookie: foulSessionUID=AUxCwMOJ7d1kE33QCVmW" -d '
{
  "userId": 7,
  "name": "login",
  "type": "success",
  "message": null
}'

# HTTP/1.1 200 OK
# Date: Sun, 22 Mar 2015 18:45:19 GMT
# Connection: keep-alive
# Transfer-Encoding: chunked
```

#### POST /create-error

** Only For Chrome **

The stack trace must be sent in a normalised way. Only Chrome is supported right now.

>
  - Errors are linked to a session via cookie
  - we can specify a stack trace, so that we can find the exact file where the error occured
  - we could link to a route via cookie


#### POST /create-timing

>
- a timing can report any duration an event took — from a http query to how long the user took to fill in the form

- `name:String` name of the event. Could be an URL, or the name of a form, etc.
- `type:String` what category is it. Could be HTTP, route, user interaction, etc.
- `message:String` a humanised name + string. ie "loading of the page http://example.com/api/"
- `duration:Integer` time elapsed in **ms**.




***

## Benchmark

Core i7, 2.5Ghz

`ab -c 10 -n 100 -p /tmp/post.data -H "Cookie: foulLastRouteUID=AUxBg1tn7d1kE33QCVgx; foulSessionUID=AUxBiHf57d1kE33QCVg1; foulLastErrorUID=AUxBiHf57d1kE33QCVg1;" http://127.0.0.1:3001/create-route`


```javascript
Concurrency Level:      10
Time taken for tests:   0.480 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      12600 bytes
Total body sent:        29800
HTML transferred:       0 bytes
Requests per second:    208.48 [#/sec] (mean)
Time per request:       47.966 [ms] (mean)
Time per request:       4.797 [ms] (mean, across all concurrent requests)
Transfer rate:          25.65 [Kbytes/sec] received
                        60.67 kb/s sent
                        86.32 kb/s total
```

This is extremely slow but it makes sense, I'm using a new Request for every transaction with elasticsearch. Using official elasticsearch package should improve our perfs.
