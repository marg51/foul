_ = require('lodash')
ES = require('./elasticsearch')
sessionManager = require('./sessionManager')

# <Object({browser: String, browserVersion: Integer, appVersion: String})>data, <Object({foulSessionUID: String})>cookies
exports.createEvent = (data, cookies) ->

    object = {}

    _.merge object, data, {date: Date.now(), sessionId: cookies.foulSessionUID, routeId: cookies.foulLastRouteUID}

    promise = ES.post('event', object).then (data) ->
        data._source = object
        return data

    sessionManager.addNested cookies.foulSessionUID, 'events', promise