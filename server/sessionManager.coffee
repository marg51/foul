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
            major   : agent.major
            minor   : agent.minor
            patch   : agent.patch
            version : agent.toVersion()
        os:
            family  : agent.os.family
            major   : agent.os.major
            minor   : agent.os.minor
            patch   : agent.os.patch
            version : agent.os.toVersion()
        device:
            family  : agent.device.family
            major   : agent.device.major
            minor   : agent.device.minor
            patch   : agent.device.patch
            version : agent.device.toVersion()

    _.merge object, data, {date: Date.now(), previousSessionId: cookies.foulSessionUID, routes: [], events: [], timing: [], errors: []}, myip, agent

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


exports.push = (session, type, data) ->

    log.displayESQuery "[NESTED]\t".cyan, type.yellow, session._id
    if not session._source[type]?
        session._source[type] = []

    object = {}

    _.merge(object,data._source, {_type: data._type, _id: data._id})

    session._source[type].push(object)
