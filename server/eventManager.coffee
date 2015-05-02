_ = require('lodash')
ES = require('./elasticsearch')
sessionManager = require('./sessionManager')

# <Object({browser: String, browserVersion: Integer, appVersion: String})>data, <Object({foulSessionUID: String})>cookies
exports.create = (data, cookies) ->

    object = {}

    _.merge object, data, {date: Date.now(), sessionId: cookies.foulSessionUID}


    return object
    promise = ES.post('event', object).then (data) ->
        data._source = object

        return data
