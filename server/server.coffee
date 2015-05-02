restify = require('restify')
_ = require('lodash')
log = require('./log')
ES = require('./elasticsearch')
sessionManager = require('./sessionManager')
errorManager = require('./errorManager')
routeManager = require('./routeManager')
eventManager = require('./eventManager')
userManager = require('./userManager')
acquisitionManager = require('./acquisitionManager')
timingManager = require('./timingManager')
CookieParser= require('restify-cookies')
async = require('async');
utils = require('./utils');

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

    # we identify the device if we haven't.
    # We don't store anything in ES *yet*, only the ID
    if not req.cookies.foulDeviceUID
        deviceUID = utils.generateId('device')
        req.cookies.foulDeviceUID = deviceUID
        res.setCookie "foulDeviceUID", deviceUID

    sessionManager.createSession(req.params, req.cookies, req.headers).then((data) ->
        res.setCookie "foulSessionUID", data._id
        res.send(200)
    ).catch(()->
        res.send(204)
    )

    next()
server.post '/create-session', createSessionFn



identifyFn = (req, res, session, params, callback) ->
    userId = _.get(params.data, 'user.id')
    token = _.get(params.data, 'user.token')

    if not userId or not token
        return callback(null, {success: false, message: "need user.id and user.token"})

    userId = "user_#{userId}"
    bulk = []
    userManager.get(userId, req.params).then((user) ->
        bulk.push({update: {_type: 'user', _id: userId}})
        bulk.push({doc: {lastLogin: Date.now()}})

        bulk.push({update: {_type: 'session', _id: session._id}})
        bulk.push({doc: {user: user._source}})

        userManager.identify(userId, session).then(() ->
            callback(null, {success: true})
        )
    ).catch((e)->
        console.log e.stack
        callback(null, {success: false, message: e.message});
    )

addAcquisitionFn = (session, event, callback) ->
    userId = _.get(session, '_source.user.id')

    if not userId
        return callback(null, {success: false, message: "need user.id"})


    userId = "user_#{userId}"
    userManager.get(userId).then((user) ->
        acquisitionManager.create(session, user, event).then ->
            callback(null, {success: true})
    ).catch((e)->
        console.log e.stack
        callback(null, {success: false, message: "acquisition: "+e.message});
    )

createRouteFn = (req, res, session, params, callback) ->

    object = routeManager.createRoute(params.data, req.cookies)
    _id = utils.generateId('route')

    object._id = _id
    object._type = "route"

    bulk = []
    bulk.push({create: { _type: "route", _id}})
    bulk.push(object)

    bulk.push({update: { _type: "session", _id: session._id, _retry_on_conflict: 5}})
    bulk.push({script: "ctx._source.routes.push(route)", params: {route: object}})

    callback(null, {bulk})


createErrorFn = (req, res, session, params, callback) ->

    object = errorManager.create(params.data, req.cookies)
    _id = utils.generateId('error')

    object._id = _id
    object._type = "error"

    bulk = []
    bulk.push({create: { _type: "error", _id}})
    bulk.push(object)

    bulk.push({update: { _type: "session", _id: session._id, _retry_on_conflict: 5}})
    bulk.push({script: "ctx._source.errors.push(error)", params: {error: object}})

    callback(null, {bulk})


createEventFn = (req, res, session, params, callback) ->

    object = eventManager.create(params.data, req.cookies)
    _id = utils.generateId('event')

    object._id = _id
    object._type = "event"

    bulk = []
    bulk.push({create: { _type: "event", _id}})
    bulk.push(object)

    bulk.push({update: { _type: "session", _id: session._id, _retry_on_conflict: 5}})
    bulk.push({script: "ctx._source.events.push(event)", params: {event: object}})

    callback(null, {bulk})

createTimingFn = (req, res, session, params, callback) ->

    object = timingManager.create(params.data, req.cookies)
    _id = utils.generateId('timing')

    object._id = _id
    object._type = "timing"

    bulk = []
    bulk.push({create: { _type: "timing", _id}})
    bulk.push(object)

    bulk.push({update: { _type: "session", _id: session._id, _retry_on_conflict: 5}})
    bulk.push({script: "ctx._source.timing.push(timing)", params: {timing: object}})

    callback(null, {bulk})

actionNotfoundFn = (req, res, session, params, callback) ->
    callback(null, {success:false, message: params.name+" doesn't exist"});

server.post '/bulk', (req, res, next) ->
    sessionManager.get(req.cookies.foulSessionUID).then((session) ->
        queries = _.map req.params, (query) ->
            # @todo frontend side
            query.data.time = query.time

            if(query.name is 'route')
                fn = createRouteFn
            else if(query.name is 'error')
                fn = createErrorFn
            else if(query.name is 'event')
                fn = createEventFn
            if(query.name is 'timing')
                fn = createTimingFn
            else if(query.name is 'identify')
                fn = identifyFn
            # else if(query.name is 'acquisition')
            #     fn = acquisitionFn
            else
                fn = actionNotfoundFn

            return (callback) ->
                fn(req, res, session, query, callback)

        async.parallel queries, (err, results) ->
            if err
                console.log "err", err
                return res.send 500



            bulk = []
            _.map results, (e, i) ->
                _.map e.bulk, (f, i) ->
                    bulk.push(f)

            ES.client.bulk({body:bulk,index: "foul"}).then((data)->
                console.log JSON.stringify(data, null, 4) if data.errors
                res.send {took: data.took, errors: data.errors}
            ).catch (e) ->
                console.log e
                res.send 500, {e: e}

    ).catch (e)->
        console.log "Not Found ?", e.stack
        res.send(404, "session not found")


    next()


Cors = (req, res, next) ->
    res.header('Access-Control-Allow-Credentials', true);
    res.header('Access-Control-Allow-Headers', 'authorizationData, Authorization, Content-Type, Accept-Encoding, Accept-Language, Cookie');
    res.header('Access-Control-Allow-Methods', '*');
    res.header('Access-Control-Allow-Origin', '*');

    return res.send(204);

server.opts '/create-session', Cors
server.opts '/bulk', Cors

server.listen 3001, ->
    console.log 'localhost:'+3001
