_ = require('lodash')
ES = require('./elasticsearch')
Promise = require('bluebird')
geoip = require('geoip-lite')
useragent = require('useragent')

require('colors')
log = require('./log')

# <Object({browser: String, browserVersion: Integer, appVersion: String})>data, <Object({foulSessionUID: String})>cookies
exports.createSession = (data, cookies, headers) ->

    object = {}

    myip = geoip.lookup(headers["x-real-ip"])

    if myip
        myip =
            location: myip.ll
            country : myip.country
            region  : myip.region
            city    : myip.city
    else myip= {}

    agent = useragent.parse(headers["user-agent"])
    agent =
        browser:
            family  : agent.family
            version : agent.toVersion()
        os:
            family  : agent.os.family
            version : agent.os.toVersion()
        device:
            family  : agent.device.family
            version : agent.device.toVersion()

    _.merge object, data, {date: Date.now(), previousSessionId: cookies.foulSessionUID}, myip, agent

    # return promsie
    ES.post('session', object)

exports.updateUserId = (sessionId, userId) ->
    exports.get(sessionId).then (data) ->
        data._source.user = id: userId

        exports.update(data)


exports.get = (sessionId) ->
    ES.get('session', sessionId)

exports.update = (session) ->
    session._source.updatedAt = Date.now()
    ES.put('session', session._id, session._source)


exports.addNested = (sessionId, type, promise) ->

    log.displayESQuery "[NESTED]\t".cyan, type.yellow, sessionId
    Promise.all([promise, exports.get(sessionId)]).then (data) ->
        object = data[0]
        session = data[1]
        session.lastUpdate = Date.now()

         # we want the _id into nested session objects
        object._source._id = object._id

        if !session._source[type]
            session._source[type] = []

        session._source[type].push object._source

        exports.update(session)
