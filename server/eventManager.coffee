_ = require('lodash')
ES = require('./elasticsearch')

# <Object({browser: String, browserVersion: Integer, appVersion: String})>data, <Object({foulSessionUID: String})>cookies
exports.createEvent = (data, cookies) ->

    object = {}

    _.merge object, data, {date: Date.now(), sessionId: cookies.foulSessionUID, routeId: cookies.foulLastRouteUID}

    # return promsie
    ES.post('event', object)
