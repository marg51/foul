_ = require('lodash')
ES = require('./elasticsearch')
sessionManager = require('./sessionManager')

# <Object({name: String, type: String, duration: Integer})>data, <Object({foulSessionUID: String})>cookies
exports.createTiming = (data, cookies) ->
    object = {}

    _.merge object, data, {date: Date.now(), sessionId: cookies.foulSessionUID}

    promise = ES.post('timing', object).then (data) ->
        data._source = object

        return data
