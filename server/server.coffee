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
async = require('async');

require('colors')


server = restify.createServer
    name:'Foul-backend'
    version: '0.0.1'

server.use restify.acceptParser(server.acceptable)
server.use restify.queryParser()
server.use restify.bodyParser()
server.use CookieParser.parse




# server.use restify.CORS({origins: ["https://.com","https://www..com"]})

sourcemap = require('./sourcemap')



createSessionFn = (req, res, next) ->
    log.displayHTTPQuery "[CREATE SESSION]\t".green
    sessionManager.createSession(req.params, req.cookies, req.headers).then((data) ->
        res.setCookie "foulSessionUID", data._id
        res.send(200)
    ).catch(()->
        res.send(204)
    )

    next()
server.post '/create-session', createSessionFn



identifyFn = (req, res, session, callback) ->
    sessionManager.updateUserId(req.cookies.foulSessionUID,req.params.userId).then(() ->
        callback(null, {success: true})
    ).catch(()->
        callback(null, {success: false});
    )
    next()


createRouteFn = (req, res, session, callback) ->
    log.displayHTTPQuery "[CREATE ROUTE]\t".cyan, "session", session._id.gray

    routeManager.createRoute(req.params, req.cookies).then((data) ->
        console.log data._id, data._type
        sessionManager.push(session, 'routes', data);

        callback(null, {sucess: true, data: id: data._id})
    ).catch((data) ->
        console.log "Can't save route".magenta, data.stack
        callback(null, {success: false, message: "can't save route"});
    )


createErrorFn = (req, res, session, callback) ->
    log.displayHTTPQuery "[CREATE ERROR]\t".cyan, "session", session._id.gray

    errorManager.createError(req.params, req.cookies).then((data) ->
        console.log data._id, data._type
        sessionManager.push(session, 'errors', data);

        callback(null, {success: true})

        if(data.type is "javascript")
            log.displayFiles(data)

    ).catch((data) ->
        console.log data.stack
        callback(null, {success: false});
    )


createEventFn = (req, res, session, callback) ->
    log.displayHTTPQuery "[CREATE EVENT]\t".cyan, "session", session._id.gray

    eventManager.createEvent(req.params, req.cookies).then((data)->
        console.log data._id, data._type
        sessionManager.push(session, 'events', data)

        callback(null, {success: true})
    ).catch(()->
        callback(null, {success: false});
    )

createTimingFn = (req, res, session, callback) ->
    log.displayHTTPQuery "[CREATE TIMING]\t".cyan, "session", session._id.gray

    timingManager.createTiming(req.params, req.cookies).then((data)->
        console.log data._id, data._type
        sessionManager.push(session, 'timing', data);

        callback(null, {success: true})
    ).catch(()->
        callback(null, {success: false});
    )


server.post '/bulk', (req, res, next) ->
    sessionManager.get(req.cookies.foulSessionUID).then((session) ->
        promises = _.map req.params, (query) ->
            # @todo frontend side
            query.data.time = query.time

            if(query.name is 'route')
                fn = createRouteFn
            else if(query.name is 'error')
                fn = createErrorFn
            else if(query.name is 'event')
                fn = createEventFn
            else if(query.name is 'timing')
                fn = createTimingFn
            else if(query.name is 'identify')
                fn = identifyFn
            else
                console.log query.name
                fn = (a,b,c,d,callback) ->
                    callback(null, {success:false, message: query.name+" doesn't exist"});

            return (callback) ->
                fn({params: query.data, cookies: req.cookies}, res, session, callback)

        async.parallel promises, (err, results) ->
            if err
                console.log "err", err
                return res.send 500

            result = []
            _.map results, (e, i) ->
                result.push(_.merge({name: req.params[i].name}, e))

            sessionManager.update(session).then ->
                res.send({result: result});
    ).catch ->
        res.send(404, "session not found")


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
