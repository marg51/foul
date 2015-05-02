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



identifyFn = (req, res, session, callback) ->
    userId = _.get(req.params, 'user.id')

    if not userId
        return callback(null, {success: false, message: "need user.id"})

    session._source.user = {id: userId};

    userId = "user_#{userId}"
    userManager.getOrCreate(userId, req.params).then((user) ->
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

        if(data._source.type is "javascript")
            log.displayFiles(data._source)

    ).catch((data) ->
        console.log data._source.stack
        callback(null, {success: false});
    )


createEventFn = (req, res, session, callback) ->
    log.displayHTTPQuery "[CREATE EVENT]\t".cyan, "session", session._id.gray

    eventManager.createEvent(req.params, req.cookies).then((data)->
        console.log data._id, data._type
        sessionManager.push(session, 'events', data)
        if req.params.type is "acquisition"
            addAcquisitionFn(session, data, callback)
        else
            callback(null, {success: true})
    ).catch((e)->
        callback(null, {success: false, message: e.message});
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
            else if(query.name is 'acquisition')
                fn = acquisitionFn
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
