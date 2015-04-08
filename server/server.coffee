restify = require('restify')
_ = require('lodash')
log = require('./log')
ES = require('./elasticsearch')
sessionManager = require('./sessionManager')
errorManager = require('./errorManager')
routeManager = require('./routeManager')
eventManager = require('./eventManager')
timingManager = require('./timingManager')
CookieParser= require('restify-cookies')

require('colors')


server = restify.createServer
    name:'Foul'
    version: '0.0.1'

server.use restify.acceptParser(server.acceptable)
server.use restify.queryParser()
server.use restify.bodyParser()
server.use CookieParser.parse




# server.use restify.CORS({origins: ["https://.com","https://www..com"]})

sourcemap = require('./sourcemap')

server.post '/create-session', (req, res, next) ->
    log.displayHTTPQuery "[CREATE SESSION]\t".green
    sessionManager.createSession(req.params, req.cookies, req.headers).then((data) ->
        res.setCookie "foulSessionUID", data._id
        res.send(200)
    ).catch(()->
        res.send(204)
    )

    next()

server.post '/identify', (req, res, next) ->
    sessionManager.updateUserId(req.cookies.foulSessionUID,req.params.userId).then(() ->
        res.send(200)
    ).catch(()->
        res.send(204)
    )
    next()

server.post '/create-route', (req, res, next) ->
    log.displayHTTPQuery "[CREATE ROUTE]\t".cyan, "session",(req.cookies.foulSessionUID||"").gray
    routeManager.createRoute(req.params, req.cookies).then((data) ->
        console.log data
        res.setCookie "foulLastRouteUID", data._id
        res.send(200)
    ).catch((data) ->
        console.log "Can't save route".magenta, data.stack
        res.send(204)
    )
    next()

server.post '/create-error', (req, res, next) ->
    log.displayHTTPQuery "[CREATE ERROR]\t".cyan, "session",(req.cookies.foulSessionUID||"").gray
    errorManager.createError(req.params, req.cookies).then((data) ->
        res.setCookie "foulLastErrorUID", data._id
        res.send 200

        if(data.type is "javascript")
            log(data)

    ).catch((data) ->
        res.send 204
    )

    next()

server.post '/create-event', (req, res, next) ->
    log.displayHTTPQuery "[CREATE EVENT]\t".cyan, "session",(req.cookies.foulSessionUID||"").gray
    eventManager.createEvent(req.params, req.cookies).then(()->
        res.send(200)
    ).catch(()->
        res.send(204)
    )
    next()

server.post '/create-timing', (req, res, next) ->
    log.displayHTTPQuery "[CREATE TIMING]\t".cyan, "session",(req.cookies.foulSessionUID||"").gray
    timingManager.createTiming(req.params, req.cookies).then(()->
        res.send(200)
    ).catch(()->
        res.send(204)
    )
    next()


Cors = (req, res, next) ->
    res.header('Access-Control-Allow-Credentials', true);
    res.header('Access-Control-Allow-Headers', 'authorizationData, Authorization, Content-Type, Accept-Encoding, Accept-Language');
    res.header('Access-Control-Allow-Methods', '*');
    res.header('Access-Control-Allow-Origin', '*');

    return res.send(204);

server.opts '/errors', Cors
server.opts '/routes', Cors

server.listen 3001, ->
    console.log 'localhost:'+3001
