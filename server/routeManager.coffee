_ = require('lodash')
ES = require('./elasticsearch')

# <Object({browser: String, browserVersion: Integer, appVersion: String})>data, <Object({foulSessionUID: String})>cookies
exports.createRoute = (data, cookies) ->

    object = {}

    _.merge object, data, {date: Date.now(), sessionId: cookies.foulSessionUID}

    # return promsie
    ES.post('route', object)