_ = require('lodash')
ES = require('./elasticsearch')
Promise = require('bluebird')
require('colors')
log = require('./log')

# <Object({browser: String, browserVersion: Integer, appVersion: String})>data, <Object({foulSessionUID: String})>cookies
exports.createSession = (data, cookies) ->

    object = {}

    _.merge object, data, {date: Date.now(), previousSessionId: cookies.foulSessionUID}

    # return promsie
    ES.post('session', object)

exports.updateUserId = (sessionId, userId) ->
    exports.get(sessionId).then (data) ->
        data._source.userId = userId

        exports.update(data)


exports.get = (sessionId) ->
    ES.get('session', sessionId)

exports.update = (session) ->
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
