_ = require('lodash')
ES = require('./elasticsearch')
sanitize = require('./utils').sanitize

# <Object({browser: String, browserVersion: Integer, appVersion: String})>data, <Object({foulSessionUID: String})>cookies
exports.createRoute = (data, cookies) ->

    object = {}

    _.merge object, data, {date: Date.now(), sessionId: cookies.foulSessionUID}

    # return promsie
    ES.post('route?parent='+sanitize(cookies.foulLastErrorUID), object)